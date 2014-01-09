//
//  DMFpsPlugin.m
//  Pods
//
//  Created by Tobias DM on 05/01/14.
//
//

#import "DMFpsPlugin.h"



@interface Fps : DMWindow
@end


@implementation Fps
{
	UILabel *label;
	CFTimeInterval previousFrameTimeStamp;
	CADisplayLink* displayLink;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.windowLevel = UIWindowLevelStatusBar + 1.0f;
		self.hidden = NO;
		
		displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(newFrame)];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	}
	return self;
}


- (void)newFrame
{
	if (previousFrameTimeStamp)
	{
		CFTimeInterval timeSinceLastFrame = displayLink.timestamp-previousFrameTimeStamp;
		double fps = 1.0/timeSinceLastFrame;
		static double fpsSmooth = 60.0f;
		double lowpass = 0.01;
		fpsSmooth = fpsSmooth * (1.0-lowpass) + fps * (lowpass);
		
		if (!label) {
			label = [UILabel new];
			[self.rootViewController.view addSubview:label];
			label.textColor = [UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleLightContent ? [UIColor whiteColor] : [UIColor blackColor];
			label.font = [UIFont boldSystemFontOfSize:12.0f];
			
			label.translatesAutoresizingMaskIntoConstraints = NO;
			[self.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
			[self.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:55.f]];
		}
		label.text = [NSString stringWithFormat:@"Fps: %.f",fpsSmooth];
	}
	previousFrameTimeStamp = displayLink.timestamp;
}

@end





@implementation DMFpsPlugin
{
	Fps *fps;
}


- (void)setup
{
	self.name = @"Fps";
	self.uniqueID = @"Fps";
	
	self.viewController = [UIViewController new];
	self.viewController.view.backgroundColor = [UIColor whiteColor];
}



- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	
	[self updateToNewSettings];
}

- (void)updateToNewSettings
{
	if (self.enabled)
	{
		if (!fps)
			fps = [Fps new];
	}
	else
	{
		fps.hidden = YES; // To remove from app windows
		fps = nil;
	}
}

@end
