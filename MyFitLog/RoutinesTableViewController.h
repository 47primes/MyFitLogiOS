//
//  RoutinesTableViewController.h
//  MyFitLog
//
//  Created by Mike Bradford on 8/8/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutinesTableViewController : UITableViewController
@property (nonatomic, retain) NSDictionary *workout;
@property (nonatomic, retain) NSMutableArray *routines;
@end
