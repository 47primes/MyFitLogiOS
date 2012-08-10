//
//  RoutinesTableViewController.m
//  MyFitLog
//
//  Created by Mike Bradford on 8/8/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import "RoutinesTableViewController.h"
#import "AppDelegate.h"
#import "CreateRoutineViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface RoutinesTableViewController ()
- (void)addRoutine;
@end

@implementation RoutinesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.routines = [NSMutableArray arrayWithArray:[self.workout objectForKey:@"routines"]];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRoutine)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
}

- (void)addRoutine
{
    CreateRoutineViewController *controller = [[CreateRoutineViewController alloc] initWithNibName:@"CreateRoutineViewController" bundle:nil];
    controller.workout = self.workout;
    [self presentModalViewController:controller animated:YES];
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
    return [self.routines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *routine = [self.routines objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [routine objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ sets of %@ reps", [routine objectForKey:@"sets"], [routine objectForKey:@"reps"]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *routine = [self.routines objectAtIndex:indexPath.row];
        NSString *routineID = [routine objectForKey:@"id"];
        NSString *workoutID = [self.workout objectForKey:@"id"];
        [self.routines removeObjectAtIndex:indexPath.row];
        
        NSURL *destroyURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/user/workouts/%d/routines/%d.json", [AppDelegate apiBaseURL], [workoutID intValue], [routineID intValue]]];
        
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

#pragma mark - Table view delegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NULL;
}

@end
