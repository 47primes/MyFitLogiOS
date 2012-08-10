//
//  ExercisesTableViewController.h
//  MyFitLog
//
//  Created by Mike Bradford on 8/10/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CreateRoutineViewController;

@interface ExercisesTableViewController : UITableViewController
@property (nonatomic, retain) CreateRoutineViewController *createRoutineViewController;
@property (nonatomic, retain) NSDictionary *routine;
@property (nonatomic, retain) NSMutableArray *exercises;
@end
