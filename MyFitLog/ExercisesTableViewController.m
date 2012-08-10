//
//  ExercisesTableViewController.m
//  MyFitLog
//
//  Created by Mike Bradford on 8/10/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import "ExercisesTableViewController.h"
#import "AppDelegate.h"
#import "CreateRoutineViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kExercisesURL [NSURL URLWithString: [NSString stringWithFormat:@"%@/user/exercises.json", [AppDelegate apiBaseURL]]]

@interface ExercisesTableViewController ()
- (void)getExercises;
@end

@implementation ExercisesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(getExercises) object:nil];
    [thread start];
}

- (void)getExercises
{
    @autoreleasepool {
        dispatch_async(kBgQueue, ^{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:kExercisesURL];
            [request setValue:@"application/vnd.my_fit_log.v2" forHTTPHeaderField:@"Accept"];
            [request setValue:@"MyFitLog iOS" forHTTPHeaderField:@"User-Agent"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[AppDelegate getValueForKey:@"api_key"] forHTTPHeaderField:@"From"];
            
            NSHTTPURLResponse *response;
            NSError *error;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if ([response statusCode] == 200) {
                self.exercises = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error]];
                [self.tableView reloadData];
            }
        });
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.exercises count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *exercise = [self.exercises objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [exercise objectForKey:@"name"];
    cell.detailTextLabel.text = [exercise objectForKey:@"name"];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *exercise = [self.exercises objectAtIndex:indexPath.row];
    
    self.createRoutineViewController.exerciseID = [exercise objectForKey:@"id"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
