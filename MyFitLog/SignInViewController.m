//
//  SignInViewController.m
//  MyFitLog
//
//  Created by Mike Bradford on 8/6/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import "SignInViewController.h"
#import "WorkoutsController.h"
#import "AppDelegate.h"
#import "NSString+Base64.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kSignInURL [NSURL URLWithString: [NSString stringWithFormat:@"%@/sessions.json", [AppDelegate apiBaseURL]]]

@interface SignInViewController ()
- (void)signIn;
@end

@implementation SignInViewController

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
    self.persistSwitch.on = [AppDelegate isPersistingApiKey];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.emailTextField = nil;
    self.passwordTextField = nil;
    self.submitButton = nil;
    self.persistSwitch = nil;
    self.signInStatusLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)signInButtonPressed
{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(signIn) object:nil];
    [thread start];
}

- (void)signIn
{
    @autoreleasepool {
        dispatch_async(kBgQueue, ^{
            NSString *emailAndPassword = [NSString stringWithFormat:@"%@:%@",self.emailTextField.text, self.passwordTextField.text];
            NSString *encodedEmailAndPassword = [emailAndPassword base64EncodedString];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:kSignInURL];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/vnd.my_fit_log.v2" forHTTPHeaderField:@"Accept"];
            [request setValue:@"MyFitLog iOS" forHTTPHeaderField:@"User-Agent"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"Basic %@", encodedEmailAndPassword] forHTTPHeaderField:@"Authorization"];
            
            NSHTTPURLResponse *response;
            NSError *error;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if ([response statusCode] == 200) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
                [AppDelegate setValue:[json valueForKey:@"api_key"] forKey:@"api_key"];
                [AppDelegate setValue:(self.persistSwitch.on ? @"YES" : @"NO") forKey:@"persist_api_key"];
                [self.parentViewController dismissModalViewControllerAnimated:YES];
            } else {
                self.signInStatusLabel.hidden = NO;
            }
        });
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.signInStatusLabel.hidden = YES;
}

@end
