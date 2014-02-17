//
//  DMGridOverlayPlugin.m
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "DMAnimationSpeedPlugin.h"





@interface AnimationSpeed : NSObject

@property (nonatomic, assign) float speed;

@end


@implementation AnimationSpeed

- (void)setSpeed:(float)speed
{
	_speed = speed;
	[self updateWindowsToSpeed];
}

- (void)updateWindowsToSpeed
{
	for (UIWindow *window in [UIApplication sharedApplication].windows) {
		window.layer.speed = _speed;
	}
}

@end






@interface AnimationView : UIView
@property (nonatomic, strong) UIView *rectView;
- (void)updateRectView;
@end

@implementation AnimationView

- (instancetype)init
{
	self = [super init];
	if (self) {
	}
	return self;
}

- (void)setFrame:(CGRect)frame
{
	super.frame = frame;
	
	[self updateRectView];
}
- (UIView *)rectView
{
	[self updateRectView];
	return _rectView;
}

- (void)updateRectView
{
	if (CGRectEqualToRect(self.frame, CGRectZero))
	{
		return;
	}
	if (CGRectGetWidth(self.frame) == 0.0) {
		return;
	}
	
	if (!_rectView)
	{
		_rectView = [UIView new];
		[self addSubview:_rectView];
		_rectView.backgroundColor = [UIColor whiteColor];
	}
	
	CGFloat size = CGRectGetHeight(self.frame);
	CGRect frame1 = CGRectMake(0, 0, size, size);
	_rectView.frame = frame1;
	
	[UIView animateWithDuration:1.0 delay:0.0
						options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 CGFloat x = CGRectGetWidth(self.frame) - CGRectGetWidth(_rectView.frame);
						 CGRect frame2 = frame1;
						 frame2.origin.x = x;
						 _rectView.frame = frame2;
					 }
					 completion:^(BOOL finished) {
					 }];
}

- (void)updateRectViewFrame
{
	CGFloat size = CGRectGetHeight(self.frame);
	self.rectView.frame = CGRectMake(CGRectGetMinX(self.rectView.frame), CGRectGetMinY(self.rectView.frame), size, size);
}

@end




@interface DMAnimationSpeedPlugin ()

@property (nonatomic, strong) AnimationSpeed *animationSpeed;
@property (nonatomic, strong) AnimationView *animationView;

@end



@implementation DMAnimationSpeedPlugin
{
	UITableView *_tableView;
}


#define cellIdentifier @"AnomationSpeedCellIdentifier"


#define kAnimationSpeed @"kAnimationSpeed"

- (void)setup
{
	self.name = @"Animation Speed";
	self.uniqueID = @"AnimationSpeed";
	self.parameterDefaults = @{kAnimationSpeed	:	@(0.1)};
	
	UITableViewController *tableViewController = [UITableViewController new];
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableViewController.tableView = _tableView;
	self.viewController = tableViewController;
	
	[tableViewController.tableView registerClass:[DMTableViewCell_StyleValue2 class] forCellReuseIdentifier:cellIdentifier];
	tableViewController.tableView.dataSource = self;
	tableViewController.tableView.delegate = self;
	
	self.animationView = [AnimationView new];
	self.animationView.frame = CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 44.0);
	_tableView.tableFooterView = self.animationView;
}



- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	
	[self updateToNewSettings];
}


- (void)updateToNewSettings
{
	float animationSpeed;
	
	if (self.enabled)
	{
		animationSpeed = [[[DMTestSettings sharedInstance] objectForKey:kAnimationSpeed withPluginIdentifier:self.uniqueID] floatValue];
	}
	else
	{
		animationSpeed = 1.0f;
	}
	self.animationSpeed.speed = animationSpeed;
}


- (NSString *)settingsDescription
{
	return [NSString stringWithFormat:@"%.2f",[[[DMTestSettings sharedInstance] objectForKey:kAnimationSpeed withPluginIdentifier:self.uniqueID] floatValue]];
}


#pragma mark -

- (AnimationSpeed *)animationSpeed
{
	if (!_animationSpeed) {
		_animationSpeed = [AnimationSpeed new];
	}
	return _animationSpeed;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"Animation";
		default: return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0: return 1;
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
					cell.textLabel.text = @"Speed";
					
					float animationSpeed = [[[DMTestSettings sharedInstance] objectForKey:kAnimationSpeed withPluginIdentifier:self.uniqueID] floatValue];
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",animationSpeed];
					
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
						stepper.minimumValue = 0.01;
						stepper.maximumValue = 10.0;
						stepper.stepValue = 0.01;
						cell.accessoryView = stepper;
					}
					stepper.value = animationSpeed;
					[stepper addTarget:self action:@selector(animationSpeedStepperChanged:) forControlEvents:UIControlEventValueChanged];
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

- (void)animationSpeedStepperChanged:(UIStepper *)stepper
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
		float animationSpeed = stepper.value;
		[[DMTestSettings sharedInstance] setObject:@(animationSpeed) forKey:kAnimationSpeed withPluginIdentifier:self.uniqueID];
		if (self.enabled) {
			self.animationSpeed.speed = animationSpeed;
			[self.animationView updateRectView];
		}
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}


@end
