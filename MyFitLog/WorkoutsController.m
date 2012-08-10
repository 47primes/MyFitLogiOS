//
//  WorkoutsController.m
//  MyFitLog
//
//  Created by Mike Bradford on 8/6/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import "WorkoutsController.h"
#import "SignInViewController.h"
#import "RoutinesTableViewController.h"
#import "AppDelegate.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kSignInURL [NSURL URLWithString: [NSString stringWithFormat:@"%@/user/workouts.json", [AppDelegate apiBaseURL]]]

@interface WorkoutsController ()
- (void)getWorkouts;
- (void)signOut;
@end

@implementation WorkoutsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(getWorkouts) object:nil];
    [thread start];
    
    UIBarButtonItem *signOutButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    
    self.navigationItem.rightBarButtonItem = signOutButtonItem;
}

- (void)getWorkouts
{
    @autoreleasepool {
        dispatch_async(kBgQueue, ^{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:kSignInURL];
            [request setValue:@"application/vnd.my_fit_log.v2" forHTTPHeaderField:@"Accept"];
            [request setValue:@"MyFitLog iOS" forHTTPHeaderField:@"User-Agent"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[AppDelegate getValueForKey:@"api_key"] forHTTPHeaderField:@"From"];
            
            NSHTTPURLResponse *response;
            NSError *error;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if ([response statusCode] == 200) {
                self.workouts = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]];
                [self.tableView reloadData];
                [self.monthView reload];
            }
        });
    }
}

- (void)signOut
{
    [AppDelegate setValue:@"" forKey:@"api_key"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![AppDelegate isSignedIn]) {
        SignInViewController *signInController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
        signInController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:signInController animated:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSMutableArray *workoutDates = [[NSMutableArray alloc] initWithCapacity:[self.workouts count]];
    for (int i=0; i<[self.workouts count]; i++) {
        NSDictionary *workout = [self.workouts objectAtIndex:i];
        NSDate *completedAt = [NSDate dateWithTimeIntervalSince1970:[[workout objectForKey:@"completed_at"] integerValue]];
        
        NSDateComponents *workoutComps = [cal components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:completedAt];
        
        [workoutDates addObject:[cal dateFromComponents:workoutComps]];
    }
    
    NSMutableArray *marks = [[NSMutableArray alloc] init];
    
    NSDateComponents *comp = [cal components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:startDate];
    NSDate *d = [cal dateFromComponents:comp];

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];

    while (YES) {
        if ([d compare:lastDate] == NSOrderedDescending) {
            break;
        }
        
        if ([workoutDates containsObject:d]) {
            [marks addObject:[NSNumber numberWithBool:YES]];
        } else {
            [marks addObject:[NSNumber numberWithBool:NO]];
        }
        
        d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
    }

    return marks;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.workouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSDictionary *workout = [self.workouts objectAtIndex:indexPath.row];
    NSDate *completedAt = [NSDate dateWithTimeIntervalSince1970:[[workout objectForKey:@"completed_at"] integerValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    cell.textLabel.text = [dateFormatter stringFromDate:completedAt];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *workout = [self.workouts objectAtIndex:indexPath.row];
        NSString *workoutID = [workout objectForKey:@"id"];
        [self.workouts removeObjectAtIndex:indexPath.row];
        
        NSURL *destroyURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/user/workouts/%d.json", [AppDelegate apiBaseURL], [workoutID intValue]]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:destroyURL];
        [request setValue:@"application/vnd.my_fit_log.v2" forHTTPHeaderField:@"Accept"];
        [request setValue:@"MyFitLog iOS" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[AppDelegate getValueForKey:@"api_key"] forHTTPHeaderField:@"From"];
        [request setHTTPMethod:@"DELETE"];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Table view delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *workout = [self.workouts objectAtIndex:indexPath.row];
    NSDate *completedAt = [NSDate dateWithTimeIntervalSince1970:[[workout objectForKey:@"completed_at"] integerValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    RoutinesTableViewController *controller = [[RoutinesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    controller.workout = workout;
    controller.navigationItem.title = [dateFormatter stringFromDate:completedAt];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
