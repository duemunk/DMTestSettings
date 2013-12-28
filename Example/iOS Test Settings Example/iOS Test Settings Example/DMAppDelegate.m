//
//  DMAppDelegate.m
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "DMAppDelegate.h"

#import "DMTestSettings.h"
#import "DMGridOverlayPlugin.h"
#import "DMColorBlindPlugin.h"


@implementation DMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
	self.window.rootViewController = [UIViewController new];
	
	// Setup view
	UILabel *label = [UILabel new];
	[self.window.rootViewController.view addSubview:label];
	label.text = @"Shake app to open test settings";
	[label sizeToFit];
	label.center = self.window.center;
	
    self.window.backgroundColor = [UIColor cyanColor];
    [self.window makeKeyAndVisible];
	
	// Start DMTestSettings _after_ setting rootViewController 
	[DMTestSettings startWithPlugins:@[[DMGridOverlayPlugin new],[DMColorBlindPlugin new]]];
	
	[DMTestSettings sharedInstance].hidden = NO;
	
    return YES;
}

@end
