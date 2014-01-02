//
//  DMTestSettingsPlugin.m
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "DMTestSettingsPlugin.h"

@implementation DMTestSettingsPlugin

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self setup];
		self.viewController.title = self.name;
		
		for (NSString *key in [self.parameterDefaults allKeys])
		{
			if (![[DMTestSettings sharedInstance] objectForKey:key withPluginIdentifier:self.uniqueID])
			{
				[[DMTestSettings sharedInstance] setObject:self.parameterDefaults[key]
													forKey:key
									  withPluginIdentifier:self.uniqueID];
			}
		}
	}
	return self;
}

- (void)setup
{ // Implement in subclass
}
- (void)updateToNewSettings
{ // Implement in subclass
}

#define kEnabled @"kEnabled"
- (BOOL)isEnabled
{
	NSNumber *num = [[DMTestSettings sharedInstance] objectForKey:kEnabled withPluginIdentifier:self.uniqueID];
	if (num) {
		return num.boolValue;
	}
	return NO; // Default
}
- (void)setEnabled:(BOOL)enabled
{
	if (enabled != self.isEnabled) {
		[[DMTestSettings sharedInstance] setObject:@(enabled) forKey:kEnabled withPluginIdentifier:self.uniqueID];
	}
}

@end
