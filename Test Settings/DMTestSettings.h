//
//  DMTestSettings.h
//  iOS Test Settings Example
//
//  Created by Tobias DM on 27/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMTableViewCell_StyleSubtitle : UITableViewCell @end
@interface DMTableViewCell_StyleValue1 : UITableViewCell @end
@interface DMTableViewCell_StyleValue2 : UITableViewCell @end



@interface DMTestSettings : NSObject

@property (nonatomic, assign) BOOL hidden;

+ (DMTestSettings *)start;
+ (DMTestSettings *)startWithPlugins:(NSArray *)plugins;
+ (DMTestSettings *)sharedInstance;

- (void)setObject:(id)object forKey:(NSString *)key withPluginIdentifier:(NSString *)pluginID;
- (id)objectForKey:(NSString *)key withPluginIdentifier:(NSString *)pluginID;

@end



