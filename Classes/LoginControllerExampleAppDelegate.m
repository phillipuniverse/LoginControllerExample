//
//  LoginControllerExampleAppDelegate.m
//  LoginControllerExample
//
//  Created by Phillip Verheyden on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginControllerExampleAppDelegate.h"
#import "UserDataViewController.h"
#import "LoginController.h"

@implementation LoginControllerExampleAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	TTNavigator *navigator = [TTNavigator navigator];
	navigator.window = window;
	navigator.persistenceMode = TTNavigatorPersistenceModeNone;
	
	TTURLMap *map = navigator.URLMap;
	//Map everything that doesn't map to something already to a web controller
	[map from:@"*" toViewController:[TTWebController class]];
	[map from:@"tt://main" toViewController:[UserDataViewController class]];
	[map from:@"tt://loginForm" toModalViewController:[LoginController class]];
    	
	/*
	 *	Reset the saved cookies (if I have any)
	 */
	NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookies"];
	if(cookiesData) {
		TTDPRINT(@"Loading saved cookie data!");
		NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
		for(NSHTTPCookie *cookie in cookies) {
			TTDPRINT(@"Reinitializing cookie: %@ => %@", cookie.name, cookie.value);;
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
		}
	}
	
	[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://main"]];
	[window makeKeyAndVisible];
	
    return YES;
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
	TTDPRINT(@"Opening url: %@", URL.absoluteString);
	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[window release];
	[super dealloc];
}


@end

