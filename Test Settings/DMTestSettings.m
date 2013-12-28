//
//  DMTestSettings.m
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "DMTestSettings.h"
#import "DMTestSettingsPlugin.h"



@protocol DMNavigationControllerDelegate <NSObject>

- (void)didShake;

@end

@interface DMNavigationController : UINavigationController
@property (nonatomic, strong) id<DMNavigationControllerDelegate> delegateShake;
@end

@implementation DMNavigationController
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
		if ([self.delegateShake respondsToSelector:@selector(didShake)])
			[self.delegateShake didShake];
    }
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)])
        [super motionEnded:motion withEvent:event];
}
@end


















@interface DMGeneralSettings : DMTestSettingsPlugin <UITableViewDataSource, UITableViewDelegate>

@end

@implementation DMGeneralSettings

#define kDisableAllPluginsOnReboot @"kDisableOnReboot"
#define kEnableShakeToShow @"kEnableShakeToShow"
#define kEnableTouchGestureToShow @"kEnableTouchGestureToShow"

#define cellIdentifier @"GeneralSettingsCellIdentifier"
- (void)setup
{
	self.uniqueID = @"GeneralSettings";
	self.name = @"General";
	self.parameterDefaults = @{kDisableAllPluginsOnReboot	:	@(NO),
							   kEnableShakeToShow			:	@(YES),
							   kEnableTouchGestureToShow	:	@(NO)};
	
	UITableViewController *tableViewController = [UITableViewController new];
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableViewController.tableView = tableView;
	self.viewController = tableViewController;
	
	[tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
	tableViewController.tableView.dataSource = self;
	tableViewController.tableView.delegate = self;
}

- (void)updateToNewSettings
{
	[self updateTouchGestureToShow];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"";
		case 1: return @"Toggle panel";
		default: return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0: return 1;
		case 1: return 2;
		default: return 0;
	}
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	cell.accessoryView = nil;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryView = nil;
	
	switch (indexPath.section) {
		case 0:
		{
			switch (indexPath.row) {
				case 0:
				{
					cell.textLabel.text = @"Disable plugins on reboot";
					UISwitch *_switch = [UISwitch new];
					_switch.on = [[[DMTestSettings sharedInstance] objectForKey:kDisableAllPluginsOnReboot withPluginIdentifier:self.uniqueID] boolValue];
					[_switch addTarget:self action:@selector(switchDisableAllPluginsOnRebootChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = _switch;
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
					cell.textLabel.text = @"Shake";
					UISwitch *_switch = [UISwitch new];
					_switch.on = [[[DMTestSettings sharedInstance] objectForKey:kEnableShakeToShow withPluginIdentifier:self.uniqueID] boolValue];
					[_switch addTarget:self action:@selector(switchEnableShakeToShowChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = _switch;
				}
					break;
				case 1:
				{
					cell.textLabel.text = @"Double tap with 2 fingers";
					UISwitch *_switch = [UISwitch new];
					_switch.on = [[[DMTestSettings sharedInstance] objectForKey:kEnableTouchGestureToShow withPluginIdentifier:self.uniqueID] boolValue];
					[_switch addTarget:self action:@selector(switchEnableGestureToShowChanged:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = _switch;
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
	
	
	return cell;
}

- (void)switchDisableAllPluginsOnRebootChanged:(UISwitch *)_switch
{
	[[DMTestSettings sharedInstance] setObject:@(_switch.on) forKey:kDisableAllPluginsOnReboot withPluginIdentifier:self.uniqueID];
}
- (void)switchEnableShakeToShowChanged:(UISwitch *)_switch
{
	BOOL enableShakeToShow = _switch.on;
	[[DMTestSettings sharedInstance] setObject:@(enableShakeToShow) forKey:kEnableShakeToShow withPluginIdentifier:self.uniqueID];
}
- (void)switchEnableGestureToShowChanged:(UISwitch *)_switch
{
	BOOL enableTouchGestureToShow = _switch.on;
	[[DMTestSettings sharedInstance] setObject:@(enableTouchGestureToShow) forKey:kEnableTouchGestureToShow withPluginIdentifier:self.uniqueID];
	
	[self updateTouchGestureToShow];
}

- (void)updateTouchGestureToShow
{
	BOOL enableTouchGestureToShow = [[[DMTestSettings sharedInstance] objectForKey:kEnableTouchGestureToShow withPluginIdentifier:self.uniqueID] boolValue];
	
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (enableTouchGestureToShow)
	{
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchGesture:)];
		tap.numberOfTapsRequired = 2;
		tap.numberOfTouchesRequired = 2;
		[window addGestureRecognizer:tap];
	}
	else
	{
		// Fint likely tap and remove
		// TODO: remove "likely"
		for (UIGestureRecognizer *gestureRecognizer in window.gestureRecognizers) {
			if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
				UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
				if (tap.numberOfTapsRequired == 2 && tap.numberOfTouchesRequired == 2)
				{
					[window removeGestureRecognizer:tap];
				}
			}
		}
	}
}

- (void)touchGesture:(UITapGestureRecognizer *)tap
{
	[DMTestSettings sharedInstance].hidden = ![DMTestSettings sharedInstance].hidden;
}

@end








@implementation DMTableViewCell_StyleSubtitle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	return self;
}
@end

@implementation DMTableViewCell_StyleValue1
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
	return self;
}
@end

@implementation DMTableViewCell_StyleValue2
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
	return self;
}
@end








#define cellIdentifier @"CellIdentifier"


@interface DMTestSettings () <DMNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *plugins;
@property (nonatomic, strong) DMNavigationController *navigationController;
@property (nonatomic, strong) UITableViewController *viewController;

@end




#import "DMGridOverlayPlugin.h"
#import "DMColorBlindPlugin.h"

@implementation DMTestSettings

@synthesize plugins = _plugins;


+ (DMTestSettings *)start
{
	return [DMTestSettings startWithPlugins:nil];
}
+ (DMTestSettings *)startWithPlugins:(NSArray *)plugins
{
	// General settings
	[[DMTestSettings sharedInstance] addPlugin:[DMGeneralSettings new]];
	// Default plugins
	[[DMTestSettings sharedInstance] addPlugin:[DMGridOverlayPlugin new]];
	[[DMTestSettings sharedInstance] addPlugin:[DMColorBlindPlugin new]];
	for (DMTestSettingsPlugin *plugin in plugins) {
		[[DMTestSettings sharedInstance] addPlugin:plugin];
	}
	return [DMTestSettings sharedInstance];
}
+ (DMTestSettings *)sharedInstance
{
    static DMTestSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [DMTestSettings new];
    });
    return sharedInstance;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		UIViewController *rootViewController = window.rootViewController;
		
		self.viewController = [UITableViewController new];
		UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		tableView.delegate = self;
		tableView.dataSource = self;
		[tableView registerClass:[DMTableViewCell_StyleSubtitle class] forCellReuseIdentifier:cellIdentifier];
		self.viewController.tableView = tableView;
		
		self.navigationController = [[DMNavigationController alloc] initWithRootViewController:self.viewController];
		self.navigationController.delegateShake = self;
		
		[rootViewController addChildViewController:self.navigationController];
		[rootViewController.view addSubview:self.navigationController.view];
		[self.navigationController didMoveToParentViewController:rootViewController];
		
		UIView *view = self.navigationController.view;
		view.translatesAutoresizingMaskIntoConstraints = NO;
		[rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topPadding)-[view]-(padding)-|"
																						options:0
																						metrics:@{@"topPadding"	: @(10+20),
																								  @"padding"	: @(10)}
																						  views:NSDictionaryOfVariableBindings(view)]];
		[rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding)-[view]-(padding)-|"
																						options:0
																						metrics:@{@"padding"	: @(10)}
																						  views:NSDictionaryOfVariableBindings(view)]];
		view.layer.shadowColor = [UIColor blackColor].CGColor;
		view.layer.shadowOpacity = 0.2f;
		view.layer.shadowRadius	= 10.0f;
		
		view.tintColor = [UIColor magentaColor];
		
		self.viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(hide)];
		
		self.hidden = YES;
	}
	return self;
}



- (void)addPlugin:(DMTestSettingsPlugin *)plugin
{
	[self.plugins addObject:plugin];
	[self reloadPlugins];
	
	if ([[[DMTestSettings sharedInstance] objectForKey:kDisableAllPluginsOnReboot withPluginIdentifier:[DMGeneralSettings new].uniqueID] boolValue]) {
		plugin.enabled = NO;
	}
	[plugin updateToNewSettings];
}

- (NSMutableArray *)plugins
{
	if (!_plugins)
		_plugins = [NSMutableArray array];
	
	return _plugins;
}
- (void)setPlugins:(NSMutableArray *)plugins
{
	if (plugins != _plugins)
	{
		_plugins = plugins;
		
		[self reloadPlugins];
	}
}


- (void)reloadPlugins
{
	[self.viewController.tableView reloadData];
}

- (void)setHidden:(BOOL)hidden
{
	if (hidden != _hidden) {
		_hidden = hidden;
		
		self.navigationController.view.hidden = hidden;
	}
}
- (void)hide
{
	self.hidden = YES;
}



- (NSString *)keyForKey:(NSString *)key withPluginIdentifier:(NSString *)pluginID
{
	return [NSString stringWithFormat:@"%@_%@",pluginID,key];
}
- (id)objectForKey:(NSString *)key withPluginIdentifier:(NSString *)pluginID
{
	NSObject *object = [[NSUserDefaults standardUserDefaults] objectForKey:[self keyForKey:key withPluginIdentifier:pluginID]];
	if ([object isKindOfClass:[NSData class]]) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)object];
	}
	return object;
}
- (void)setObject:(id)object forKey:(NSString *)key withPluginIdentifier:(NSString *)pluginID
{
	if ([object isKindOfClass:[UIColor class]]) {
		object = [NSKeyedArchiver archivedDataWithRootObject:object];
	}
	[[NSUserDefaults standardUserDefaults] setObject:object forKey:[self keyForKey:key withPluginIdentifier:pluginID]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.viewController.tableView reloadData];
}



#pragma mark - DMViewControllerDelegate

- (void)didShake
{
	if ([[[DMTestSettings sharedInstance] objectForKey:kEnableShakeToShow withPluginIdentifier:[DMGeneralSettings new].uniqueID] boolValue]) {
		self.hidden = !self.hidden;
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.plugins.count;
}

#pragma mark -

- (DMTestSettingsPlugin *)pluginForRow:(NSInteger)row
{
	return self.plugins[row];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	cell.detailTextLabel.textColor = [UIColor grayColor];
	
	DMTestSettingsPlugin *plugin = [self pluginForRow:indexPath.row];
	NSAssert(plugin.name.length > 0, @"Plugin doesn't have name: Class %@",[plugin class]);
	cell.textLabel.text = plugin.name;
	cell.detailTextLabel.text = plugin.settingsDescription;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if ([plugin isKindOfClass:[DMGeneralSettings class]]) {
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		UISwitch *_switch = [UISwitch new];
		_switch.on = plugin.isEnabled;
		[_switch addTarget:self action:@selector(switchEnableChanged:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = _switch;
	}
	
	
	return cell;
}

#pragma mark -

- (void)switchEnableChanged:(UISwitch *)_switch
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
		NSIndexPath *indexPath = [self.viewController.tableView indexPathForCell:cell];
		[self pluginForRow:indexPath.row].enabled = _switch.on;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DMTestSettingsPlugin *plugin = [self pluginForRow:indexPath.row];
	NSAssert(plugin.viewController, @"Plugin doesn't have viewController: Class %@",[plugin class]);
	
	UIViewController *viewController = plugin.viewController;
	[self.navigationController pushViewController:viewController animated:YES];
	viewController.navigationItem.rightBarButtonItem = self.viewController.navigationItem.rightBarButtonItem;
}

@end