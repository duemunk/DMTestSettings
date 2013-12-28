//
//  DMGridOverlayPlugin.m
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//



@interface GridOverlay : UIWindow

@property (nonatomic, assign) NSUInteger verticalSpacing, horizontalSpacing, lineWidth;
@property (nonatomic, strong) UIColor *lineColor;

+ (GridOverlay *)sharedInstance;

@end


@implementation GridOverlay

+ (GridOverlay *)sharedInstance
{
    static GridOverlay *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [GridOverlay new];
    });
    return sharedInstance;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.windowLevel = UIWindowLevelStatusBar + 1.0f;
		self.alpha = 0.2f;
		self.frame = [UIScreen mainScreen].bounds;
		
		self.backgroundColor = [UIColor clearColor];
		
		self.userInteractionEnabled = NO;
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	if (!self.hidden) {
		float x = rect.origin.x;
		float y = rect.origin.y;
		
		UIBezierPath *topPath = [UIBezierPath bezierPath];
		// draw vertical lines
		while (x < rect.origin.x + rect.size.width)
		{
			x += self.horizontalSpacing;
			[topPath moveToPoint:CGPointMake(x, 0)];
			[topPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height)];
		}
		
		// draw horizontal lines
		while (y < rect.origin.y + rect.size.height)
		{
			y += self.verticalSpacing;
			[topPath moveToPoint:CGPointMake(0, y)];
			[topPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, y)];
		}
		
		[self.lineColor setStroke];
		topPath.lineWidth = self.lineWidth;
		
		[topPath stroke];
	}
}

- (void)setHidden:(BOOL)hidden
{
	super.hidden = hidden;
	
	[self setNeedsDisplay];
}

@end






#import "DMGridOverlayPlugin.h"

@implementation DMGridOverlayPlugin


#define cellIdentifier @"GridOverlayCellIdentifier"


#define kHorizontalSpacing @"kHorizontalSpacing"
#define kVerticalSpacing @"kVerticalSpacing"
#define kLineWidth @"kLineWidth"
#define kLineColor @"kLineColor"

- (void)setup
{
	self.name = @"Grid Overlay";
	self.uniqueID = @"GridOverlay";
	self.parameterDefaults = @{kHorizontalSpacing	:	@(20),
							   kVerticalSpacing		:	@(20),
							   kLineWidth			:	@(2),
							   kLineColor			:	[UIColor grayColor]};
	
	UITableViewController *tableViewController = [UITableViewController new];
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableViewController.tableView = tableView;
	self.viewController = tableViewController;
	
	[tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
	tableViewController.tableView.dataSource = self;
	tableViewController.tableView.delegate = self;
}



- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	
	[self updateToNewSettings];
}

- (void)updateToNewSettings
{
	[GridOverlay sharedInstance].hidden = !self.enabled;
	[GridOverlay sharedInstance].verticalSpacing = [[[DMTestSettings sharedInstance] objectForKey:kVerticalSpacing withPluginIdentifier:self.uniqueID] floatValue];
	[GridOverlay sharedInstance].horizontalSpacing = [[[DMTestSettings sharedInstance] objectForKey:kHorizontalSpacing withPluginIdentifier:self.uniqueID] floatValue];
	[GridOverlay sharedInstance].lineColor = [[DMTestSettings sharedInstance] objectForKey:kLineColor withPluginIdentifier:self.uniqueID];
	[GridOverlay sharedInstance].lineWidth = [[[DMTestSettings sharedInstance] objectForKey:kLineWidth withPluginIdentifier:self.uniqueID] floatValue];
}


- (NSString *)settingsDescription
{
	return [NSString stringWithFormat:@"%d, %d",[[[DMTestSettings sharedInstance] objectForKey:kVerticalSpacing withPluginIdentifier:self.uniqueID] intValue],[[[DMTestSettings sharedInstance] objectForKey:kHorizontalSpacing withPluginIdentifier:self.uniqueID] intValue]];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"Parameters";
		default: return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0: return 4;
		default: return 0;
	}
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	cell.accessoryView = nil;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	
	switch (indexPath.section) {
		case 0:
		{
			
		}
			break;
		case 1:
		{
			
		}
			break;
			
		default:
			break;
	}
	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}







@end
