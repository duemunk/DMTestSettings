//
//  DMGridOverlayPlugin.m
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "DMGridOverlayPlugin.h"



@interface GridOverlay : DMWindow

@property (nonatomic, assign) NSUInteger verticalSpacing, horizontalSpacing, lineWidth;
@property (nonatomic, assign) BOOL exludeStatusBar;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) double opacity;

@end


@implementation GridOverlay

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.hidden = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	}
	return self;
}

- (CGFloat)getStatusBarHeight
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	CGSize s = [UIApplication sharedApplication].statusBarFrame.size;
    return UIInterfaceOrientationIsLandscape(orientation) ? s.width : s.height;
}

- (void)drawRect:(CGRect)rect
{
	if (!self.hidden)
	{
		float initialX = rect.origin.x;
		float initialY = rect.origin.y;
		
		float endX = rect.origin.x + rect.size.width;
		float endY = rect.origin.y + rect.size.height;
	
		UIInterfaceOrientation orienation = [UIApplication sharedApplication].statusBarOrientation;
		BOOL portrait = UIInterfaceOrientationIsPortrait(orienation);
		BOOL upsideDown = (orienation == UIInterfaceOrientationPortraitUpsideDown) || (orienation == UIInterfaceOrientationLandscapeRight);
		
		if (self.exludeStatusBar)
		{
			if (upsideDown)
			{
				if (portrait)
				{
					endY -= [self getStatusBarHeight];
					initialY += fmod(endY-initialY, self.verticalSpacing) - self.verticalSpacing; // Offset to fake draw from top
				}
				else
				{
					endX -= [self getStatusBarHeight];
					initialX += fmod(endX - initialX, self.verticalSpacing) - self.verticalSpacing; // Offset to fake draw from top
				}
			}
			else
			{
				if (portrait)
					initialY += [self getStatusBarHeight];
				else
					initialX += [self getStatusBarHeight];
			}
		}
		
		float x = initialX;
		float y = initialY;
		
		UIBezierPath *topPath = [UIBezierPath bezierPath];
		// draw vertical lines
		while (x <= endX)
		{
			[topPath moveToPoint:CGPointMake(x, initialY)];
			[topPath addLineToPoint:CGPointMake(x, endY)];
			x += portrait ? self.horizontalSpacing : self.verticalSpacing;
		}
		
		// draw horizontal lines
		while (y <= endY)
		{
			[topPath moveToPoint:CGPointMake(initialX, y)];
			[topPath addLineToPoint:CGPointMake(endX, y)];
			y += portrait ? self.verticalSpacing : self.horizontalSpacing;
		}
		
		[self.lineColor setStroke];
		topPath.lineWidth = self.lineWidth;
		
		[topPath stroke];
	}
}

- (void)setVerticalSpacing:(NSUInteger)verticalSpacing
{
	if (verticalSpacing != _verticalSpacing) {
		_verticalSpacing = verticalSpacing;
		
		[self setNeedsDisplay];
	}
}
- (void)setHorizontalSpacing:(NSUInteger)horizontalSpacing
{
	if (horizontalSpacing != _horizontalSpacing) {
		_horizontalSpacing = horizontalSpacing;
		
		[self setNeedsDisplay];
	}
}
- (void)setLineWidth:(NSUInteger)lineWidth
{
	if (lineWidth != _lineWidth) {
		_lineWidth = lineWidth;
		
		[self setNeedsDisplay];
	}
}
- (void)setExludeStatusBar:(BOOL)exludeStatusBar
{
	if (exludeStatusBar != _exludeStatusBar) {
		_exludeStatusBar = exludeStatusBar;
		
		[self setNeedsDisplay];
	}
}

- (void)setOpacity:(double)opacity
{
	if (opacity != _opacity) {
		_opacity = opacity;
		
		self.alpha = 1.0 - _opacity;
	}
}
@end














@implementation DMGridOverlayPlugin
{
	UITableView *_tableView;
	GridOverlay *gridOverlay;
}


#define cellIdentifier @"GridOverlayCellIdentifier"


#define kHorizontalSpacing @"kHorizontalSpacing"
#define kVerticalSpacing @"kVerticalSpacing"
#define kExludeStatusBar @"kExludeStatusBar"
#define kLineWidth @"kLineWidth"
#define kLineColor @"kLineColor"
#define kOpacity @"kOpacity"

- (void)setup
{
	self.name = @"Grid Overlay";
	self.uniqueID = @"GridOverlay";
	self.parameterDefaults = @{kHorizontalSpacing	:	@(20),
							   kVerticalSpacing		:	@(20),
							   kExludeStatusBar		:	@YES,
							   kLineWidth			:	@(2),
							   kLineColor			:	[UIColor grayColor],
							   kOpacity				:	@(0.8f)};
	
	UITableViewController *tableViewController = [UITableViewController new];
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableViewController.tableView = _tableView;
	self.viewController = tableViewController;
	
	[tableViewController.tableView registerClass:[DMTableViewCell_StyleValue2 class] forCellReuseIdentifier:cellIdentifier];
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
	if (self.enabled)
	{
		if (!gridOverlay)
			gridOverlay = [GridOverlay new];
		
		gridOverlay.verticalSpacing = [[[DMTestSettings sharedInstance] objectForKey:kVerticalSpacing withPluginIdentifier:self.uniqueID] floatValue];
		gridOverlay.horizontalSpacing = [[[DMTestSettings sharedInstance] objectForKey:kHorizontalSpacing withPluginIdentifier:self.uniqueID] floatValue];
		gridOverlay.exludeStatusBar = [[[DMTestSettings sharedInstance] objectForKey:kExludeStatusBar withPluginIdentifier:self.uniqueID] boolValue];
		gridOverlay.lineColor = [[DMTestSettings sharedInstance] objectForKey:kLineColor withPluginIdentifier:self.uniqueID];
		gridOverlay.lineWidth = [[[DMTestSettings sharedInstance] objectForKey:kLineWidth withPluginIdentifier:self.uniqueID] floatValue];
		gridOverlay.opacity = [[[DMTestSettings sharedInstance] objectForKey:kOpacity withPluginIdentifier:self.uniqueID] floatValue];
	}
	else
	{
		gridOverlay.hidden = YES; // To remove from app windows
		gridOverlay = nil;
	}
}


- (NSString *)settingsDescription
{
	return [NSString stringWithFormat:@"h:%d v:%d px",[[[DMTestSettings sharedInstance] objectForKey:kVerticalSpacing withPluginIdentifier:self.uniqueID] intValue],[[[DMTestSettings sharedInstance] objectForKey:kHorizontalSpacing withPluginIdentifier:self.uniqueID] intValue]];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"Spacing";
		case 1: return @"Line";
		default: return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0: return 3;
		case 1: return 2;
		default: return 0;
	}
}

#pragma mark - UITableViewDelegate


#define stepperViewTag 218734619
#define switchViewTag 120934875
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	[self configureCell:cell forIndexPath:indexPath];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}


#pragma mark -

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	
	cell.textLabel.textColor = [UIColor grayColor];
	
	switch (indexPath.section) {
		case 0:
		{
			switch (indexPath.row) {
				case 0:
				{
					cell.textLabel.text = @"Horizontal";
					
					int spacing = [[[DMTestSettings sharedInstance] objectForKey:kHorizontalSpacing withPluginIdentifier:self.uniqueID] intValue];
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d px",spacing];
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					
					UIStepper *stepper;
					if (cell.accessoryView.tag == stepperViewTag)
					{
						stepper = (UIStepper *)cell.accessoryView;
						[stepper removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
					}
					else
					{
						stepper = [UIStepper new];
						stepper.tag = stepperViewTag;
						stepper.minimumValue = 2;
						cell.accessoryView = stepper;
					}
					stepper.value = spacing;
					[stepper addTarget:self action:@selector(horizontalStepperChanged:) forControlEvents:UIControlEventValueChanged];
				}
					break;
				case 1:
				{
					cell.textLabel.text = @"Vertical";
					
					int spacing = [[[DMTestSettings sharedInstance] objectForKey:kVerticalSpacing withPluginIdentifier:self.uniqueID] intValue];
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d px",spacing];
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					
					UIStepper *stepper;
					if (cell.accessoryView.tag == stepperViewTag)
					{
						stepper = (UIStepper *)cell.accessoryView;
						[stepper removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
					}
					else
					{
						stepper = [UIStepper new];
						stepper.tag = stepperViewTag;
						stepper.minimumValue = 2;
						cell.accessoryView = stepper;
					}
					stepper.value = spacing;
					[stepper addTarget:self action:@selector(verticalStepperChanged:) forControlEvents:UIControlEventValueChanged];
				}
					break;
				case 2:
				{
					cell.textLabel.text = @"Exlude status bar";
					
					int exludeStatusBar = [[[DMTestSettings sharedInstance] objectForKey:kExludeStatusBar withPluginIdentifier:self.uniqueID] boolValue];
					cell.detailTextLabel.text = nil;
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					
					UISwitch *_switch;
					if (cell.accessoryView.tag == switchViewTag)
					{
						_switch = (UISwitch *)cell.accessoryView;
						[_switch removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
					}
					else
					{
						_switch = [UISwitch new];
						_switch.tag = switchViewTag;
						cell.accessoryView = _switch;
					}
					_switch.on = exludeStatusBar;
					[_switch addTarget:self action:@selector(exludeStatusBarSwitchChanged:) forControlEvents:UIControlEventValueChanged];
				}
					break;
					
				default:
					break;
			}
		}
			break;
		case 1:
		{
			switch (indexPath.row) {
				case 0:
				{
					cell.textLabel.text = @"Width";
					
					int lineWidth = [[[DMTestSettings sharedInstance] objectForKey:kLineWidth withPluginIdentifier:self.uniqueID] intValue];
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d px",lineWidth];
					[cell.detailTextLabel sizeToFit];
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					
					UIStepper *stepper;
					if (cell.accessoryView.tag == stepperViewTag)
					{
						stepper = (UIStepper *)cell.accessoryView;
						[stepper removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
					}
					else
					{
						stepper = [UIStepper new];
						stepper.tag = stepperViewTag;
						stepper.minimumValue = 1;
						cell.accessoryView = stepper;
					}
					stepper.value = lineWidth;

					[stepper addTarget:self action:@selector(lineWidthStepperChanged:) forControlEvents:UIControlEventValueChanged];
				}
					break;
				case 1:
				{
					cell.textLabel.text = @"Opacity";
					
					float opacity = [[[DMTestSettings sharedInstance] objectForKey:kOpacity withPluginIdentifier:self.uniqueID] floatValue];
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.f %%",opacity*100];
					[cell.detailTextLabel sizeToFit];
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					
					UIStepper *stepper;
					if (cell.accessoryView.tag == stepperViewTag)
					{
						stepper = (UIStepper *)cell.accessoryView;
						[stepper removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
					}
					else
					{
						stepper = [UIStepper new];
						stepper.tag = stepperViewTag;
						stepper.minimumValue = 0.0f;
						stepper.maximumValue = 1.0f;
						stepper.stepValue = 0.05f;
						cell.accessoryView = stepper;
					}
					stepper.value = opacity;
					
					[stepper addTarget:self action:@selector(opacityStepperChanged:) forControlEvents:UIControlEventValueChanged];
				}
					break;
					
				default:
					break;
			}
		}
			break;
			
		default:
			break;
	}
}

- (void)horizontalStepperChanged:(UIStepper *)stepper
{
	UITableViewCell *cell;
	if ([stepper.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)stepper.superview;
	}
	else if ([stepper.superview.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)stepper.superview.superview;
	}
	if (cell)
	{
		int spacing = stepper.value;
		[[DMTestSettings sharedInstance] setObject:@(spacing) forKey:kHorizontalSpacing withPluginIdentifier:self.uniqueID];
		if (gridOverlay)
			gridOverlay.horizontalSpacing = spacing;
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}

- (void)verticalStepperChanged:(UIStepper *)stepper
{
	UITableViewCell *cell;
	if ([stepper.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)stepper.superview;
	}
	else if ([stepper.superview.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)stepper.superview.superview;
	}
	if (cell)
	{
		int spacing = stepper.value;
		[[DMTestSettings sharedInstance] setObject:@(spacing) forKey:kVerticalSpacing withPluginIdentifier:self.uniqueID];
		if (gridOverlay)
			gridOverlay.verticalSpacing = spacing;
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}

- (void)exludeStatusBarSwitchChanged:(UISwitch *)_switch
{
	UITableViewCell *cell;
	if ([_switch.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)_switch.superview;
	}
	else if ([_switch.superview.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)_switch.superview.superview;
	}
	if (cell)
	{
		int exludeStatusBar = _switch.on;
		[[DMTestSettings sharedInstance] setObject:@(exludeStatusBar) forKey:kExludeStatusBar withPluginIdentifier:self.uniqueID];
		if (gridOverlay)
			gridOverlay.exludeStatusBar = exludeStatusBar;
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}

- (void)lineWidthStepperChanged:(UIStepper *)stepper
{
	UITableViewCell *cell;
	if ([stepper.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)stepper.superview;
	}
	else if ([stepper.superview.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)stepper.superview.superview;
	}
	if (cell)
	{
		int lineWidth = stepper.value;
		[[DMTestSettings sharedInstance] setObject:@(lineWidth) forKey:kLineWidth withPluginIdentifier:self.uniqueID];
		if (gridOverlay)
			gridOverlay.lineWidth = lineWidth;
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}

- (void)opacityStepperChanged:(UIStepper *)stepper
{
	UITableViewCell *cell;
	if ([stepper.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)stepper.superview;
	}
	else if ([stepper.superview.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)stepper.superview.superview;
	}
	if (cell)
	{
		double opacity = stepper.value;
		[[DMTestSettings sharedInstance] setObject:@(opacity) forKey:kOpacity withPluginIdentifier:self.uniqueID];
		if (gridOverlay)
			gridOverlay.opacity = opacity;
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}







@end
