//
//  DMTestSettingsPlugin.h
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DMTestSettings.h"

@interface DMTestSettingsPlugin : NSObject

@property (nonatomic, strong) NSString *uniqueID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) NSString *settingsDescription;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, strong) NSDictionary *parameterDefaults;

- (void)setup;
- (void)updateToNewSettings;

@end
