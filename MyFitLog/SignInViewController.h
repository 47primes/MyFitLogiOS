//
//  SignInViewController.h
//  MyFitLog
//
//  Created by Mike Bradford on 8/6/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIButton *submitButton;

- (IBAction)signInButtonPressed;

@end
