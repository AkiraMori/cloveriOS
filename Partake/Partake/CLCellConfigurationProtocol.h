//
//  CLCellConfigurationProtocol.h
//  Partake
//
//  Created by Pablo Episcopo on 3/5/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLCellConfigurationProtocol <NSObject>

@optional
- (void)configureCellAppearanceWithData:(id)data;
- (void)configureCellWithDictionary:(NSDictionary *)dictionary;

@end