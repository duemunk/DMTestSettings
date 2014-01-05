//
//  DMFpsPlugin.m
//  Pods
//
//  Created by Tobias DM on 05/01/14.
//
//

#import "DMFpsPlugin.h"



@interface Fps : DMWindow
+ (Fps *)sharedInstance;
@end


@implementation Fps
{
	UILabel *label;
	CFTimeInterval previousFrameTimeStamp;
	CADisplayLink* displayLink;
}

+ (Fps *)sharedInstance
{
    static Fps *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [Fps new];
    });
    return sharedInstance;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
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
		fpsSmooth = fpsSmooth * 0.9 + fps * 0.1;
		
		if (!label) {
			label = [UILabel new];
			[self addSubview:label];
			label.textColor = [UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleLightContent ? [UIColor whiteColor] : [UIColor blackColor];
			label.font = [UIFont boldSystemFontOfSize:12.0f];
		}
		label.text = [NSString stringWithFormat:@"Fps: %.f",fpsSmooth];
		label.frame = CGRectMake(self.frame.size.width/2-70, 0, 50, 20.0f);
	}
	previousFrameTimeStamp = displayLink.timestamp;
}

@end





@implementation DMFpsPlugin



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
	[Fps sharedInstance].hidden = !self.enabled;
}

@end
