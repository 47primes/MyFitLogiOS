//
//  AppDelegate.m
//  MyFitLog
//
//  Created by Mike Bradford on 8/6/12.
//  Copyright (c) 2012 Mike Bradford. All rights reserved.
//

#import "AppDelegate.h"
#import "WorkoutsController.h"
#import "SignInViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([AppDelegate isSignedIn]) {
        WorkoutsController *workoutsController = [[WorkoutsController alloc] initWithSunday:YES];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:workoutsController];
    } else {
        SignInViewController *signInController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:signInController];
    }
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

+ (NSString *)apiBaseURL
{
    return @"http://localhost:3000";
}

+ (NSString *)authDictionaryPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: @"Authentication.plist"];
}

+ (NSMutableDictionary *)authDictionary
{
    NSString *pListPath = [self authDictionaryPath];
    return [NSMutableDictionary dictionaryWithContentsOfFile:pListPath];
}

+ (id)getValueForKey:(id)key
{
    return [[self authDictionary] objectForKey:key];
}

+ (void)setValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary *authDictionary = [[NSMutableDictionary alloc] init];
    [authDictionary setDictionary:[self authDictionary]];
    [authDictionary setObject:value forKey:key];
    if (![authDictionary writeToFile:[self authDictionaryPath] atomically:YES]) {
        NSError *error;
        [NSException raise:@"SettingsException" format:@"There was a problem changing this setting.\n%@", error];
	}
}

+ (BOOL)isSignedIn
{
    return [(NSString *)[self getValueForKey:@"api_key"] length] > 0;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (![AppDelegate getValueForKey:@"persist_api_key"]) {
        [AppDelegate setValue:@"" forKey:@"api_key"];
    }
}

@end
