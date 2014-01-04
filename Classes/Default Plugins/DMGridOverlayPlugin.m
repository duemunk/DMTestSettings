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

- (void)drawRect:(CGRect)rect
{
	if (!self.hidden) {
		float initialX = rect.origin.x;
		float initialY = rect.origin.y;
		initialY += self.exludeStatusBar ? 20.0f : 0.0f;
		
		float x = initialX;
		float y = initialY;
		
		UIBezierPath *topPath = [UIBezierPath bezierPath];
		// draw vertical lines
		while (x < rect.origin.x + rect.size.width)
		{
			[topPath moveToPoint:CGPointMake(x, initialY)];
			[topPath addLineToPoint:CGPointMake(x, rect.origin.y + rect.size.height)];
			x += self.horizontalSpacing;
		}
		
		// draw horizontal lines
		while (y < rect.origin.y + rect.size.height)
		{
			[topPath moveToPoint:CGPointMake(initialX, y)];
			[topPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, y)];
			y += self.verticalSpacing;
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
	[GridOverlay sharedInstance].hidden = !self.enabled;
	[GridOverlay sharedInstance].verticalSpacing = [[[DMTestSettings sharedInstance] objectForKey:kVerticalSpacing withPluginIdentifier:self.uniqueID] floatValue];
	[GridOverlay sharedInstance].horizontalSpacing = [[[DMTestSettings sharedInstance] objectForKey:kHorizontalSpacing withPluginIdentifier:self.uniqueID] floatValue];
	[GridOverlay sharedInstance].exludeStatusBar = [[[DMTestSettings sharedInstance] objectForKey:kExludeStatusBar withPluginIdentifier:self.uniqueID] boolValue];
	[GridOverlay sharedInstance].lineColor = [[DMTestSettings sharedInstance] objectForKey:kLineColor withPluginIdentifier:self.uniqueID];
	[GridOverlay sharedInstance].lineWidth = [[[DMTestSettings sharedInstance] objectForKey:kLineWidth withPluginIdentifier:self.uniqueID] floatValue];
	[GridOverlay sharedInstance].opacity = [[[DMTestSettings sharedInstance] objectForKey:kOpacity withPluginIdentifier:self.uniqueID] floatValue];
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
		[GridOverlay sharedInstance].horizontalSpacing = spacing;
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
		[GridOverlay sharedInstance].verticalSpacing = spacing;
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
		[GridOverlay sharedInstance].exludeStatusBar = exludeStatusBar;
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
		[GridOverlay sharedInstance].lineWidth = lineWidth;
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
		[GridOverlay sharedInstance].opacity = opacity;
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}







@end
