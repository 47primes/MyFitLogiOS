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
@end

@implementation WorkoutsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(getWorkouts) object:nil];
    [thread start];
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
                self.workouts = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
                [self.tableView reloadData];
                [self.monthView reload];
            }
        });
    }
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

#pragma mark - Table view delegate

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
