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

@end












#import "DMGridOverlayPlugin.h"

@implementation DMGridOverlayPlugin
{
	UITableView *_tableView;
}


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
	[GridOverlay sharedInstance].lineColor = [[DMTestSettings sharedInstance] objectForKey:kLineColor withPluginIdentifier:self.uniqueID];
	[GridOverlay sharedInstance].lineWidth = [[[DMTestSettings sharedInstance] objectForKey:kLineWidth withPluginIdentifier:self.uniqueID] floatValue];
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
		case 0: return 2;
		case 1: return 2;
		default: return 0;
	}
}

#pragma mark - UITableViewDelegate


#define stepperViewTag 218734619
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
					cell.accessoryView = nil;
					
					cell.textLabel.text = @"Color";
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
		int spacing = stepper.value;
		[[DMTestSettings sharedInstance] setObject:@(spacing) forKey:kLineWidth withPluginIdentifier:self.uniqueID];
		[GridOverlay sharedInstance].lineWidth = spacing;
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}







@end
