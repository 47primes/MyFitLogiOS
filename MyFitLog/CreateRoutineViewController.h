//
//  CreateRoutineViewController.h
//  MyFitLog
//
//  Created by Mike Bradford on 8/10/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateRoutineViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) NSDictionary *workout;
@property (nonatomic, retain) NSString *exerciseID;

@property (nonatomic, retain) IBOutlet UITextField *setsTextField;
@property (nonatomic, retain) IBOutlet UITextField *repsTextField;
@property (nonatomic, retain) IBOutlet UIButton *exerciseButton;

- (IBAction)chooseExercise:(id)sender;

@end
