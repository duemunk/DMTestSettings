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


@interface ViewController : UIViewController
@end

@implementation ViewController

- (void)viewDidLoad
{
	// Setup view
	UILabel *label = [UILabel new];
	[self.view addSubview:label];
	label.text = @"Shake app to open test settings \n\n or ⌃⌘Z in Simulator";
	label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	label.textColor = [UIColor whiteColor];
	label.numberOfLines = 0;
	label.textAlignment = NSTextAlignmentCenter;
	NSDictionary *views = NSDictionaryOfVariableBindings(label);
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[label]-padding-|"
																								options:0
																								metrics:@{@"padding":@(20)}
																								  views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[label]-padding-|"
																								options:0
																								metrics:@{@"padding":@(20)}
																								  views:views]];
	
    self.view.backgroundColor = [UIColor cyanColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

@end



@implementation DMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
	self.window.rootViewController = [ViewController new];
	
	
    [self.window makeKeyAndVisible];
	
	// Start DMTestSettings _after_ setting rootViewController 
	[DMTestSettings startWithPlugins:@[[DMGridOverlayPlugin new],[DMColorBlindPlugin new]]];
	
//	[DMTestSettings sharedInstance].hidden = NO;
	
    return YES;
}

@end
