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
+ (NSString *)authDictionaryPath;
+ (NSMutableDictionary *)authDictionary;
+ (NSString *)getValueForKey:(NSString *)key;
+ (void)setValue:(NSString *)value forKey:(NSString *)key;
+ (BOOL)isSignedIn;
+ (BOOL)isPersistingApiKey;

@end
