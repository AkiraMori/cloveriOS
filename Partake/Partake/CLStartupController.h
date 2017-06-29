//
//  StartupController.h
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "DDLog.h"

extern int const ddLogLevel;

@interface CLStartupController : NSObject

+ (void)kickoffWithOptions:(NSDictionary *)options;

@end
