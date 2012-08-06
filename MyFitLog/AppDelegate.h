//
//  AppDelegate.h
//  MyFitLog
//
//  Created by Mike Bradford on 8/6/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

+ (NSString *)apiBaseURL;
+ (NSString *)authenticationDataPlistPath;
+ (NSMutableDictionary *)authenticationData;
+ (NSString *)apiKey;
+ (void)setApiKey:(NSString *)apiKey;
+ (BOOL)isSignedIn;

@end
