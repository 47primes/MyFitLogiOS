//
//  CreateRoutineViewController.m
//  MyFitLog
//
//  Created by Mike Bradford on 8/10/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import "CreateRoutineViewController.h"
#import "AppDelegate.h"

@interface CreateRoutineViewController ()

@end

@implementation CreateRoutineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    saveButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.setsTextField = nil;
    self.repsTextField = nil;
    self.exerciseButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)chooseExercise:(id)sender
{
    
}

- (void)save:(id)sender
{
    NSString *workoutID = [self.workout objectForKey:@"id"];
    
    NSURL *destroyURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/user/workouts/%d/routines.json", [AppDelegate apiBaseURL], [workoutID intValue]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:destroyURL];
    [request setValue:@"application/vnd.my_fit_log.v2" forHTTPHeaderField:@"Accept"];
    [request setValue:@"MyFitLog iOS" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[AppDelegate getValueForKey:@"api_key"] forHTTPHeaderField:@"From"];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary* routine = [NSDictionary dictionaryWithObjectsAndKeys: self.repsTextField.text, @"reps",
                          self.setsTextField.text, @"sets", self.exerciseID, @"exercise_id", nil];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //[self dismissModalViewControllerAnimated:YES];
}

@end
