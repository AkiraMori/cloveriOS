//
//  FileFunctionLevelFormatter.m
//
//  Created by Julien Grimault on 23/1/12.
//  Copyright (c) 2012 Julien Grimault. All rights reserved.
//

#import "FileFunctionLevelFormatter.h"

@implementation FileFunctionLevelFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel = nil;
    
    switch (logMessage->_level) {
        case DDLogLevelError    : logLevel = @"E"; break;
        case DDLogLevelWarning  : logLevel = @"W"; break;
        case DDLogLevelInfo     : logLevel = @"I"; break;
        default                 : logLevel = @"V"; break;
    }
    
    return [NSString stringWithFormat:@"[%@][%@ %@][Line %lu] %@",
            logLevel,
            logMessage.fileName,
            logMessage.function,
            (unsigned long)logMessage->_line,
            logMessage->_message];
}

@end