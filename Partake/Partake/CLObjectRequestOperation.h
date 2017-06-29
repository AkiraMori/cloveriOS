//
//  CLObjectRequestOperation.h
//  Partake
//
//  Created by Pablo Episcopo on 2/11/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "RKObjectRequestOperation.h"

@interface CLApiErrorDetector : NSObject

@property (strong, nonatomic) id JSON;
@property (strong, nonatomic) NSData *data;

- (id)initWithJSON:(id)JSON;
- (id)initWithData:(NSData *)data;

- (NSError *)detect;

@end

@interface CLObjectRequestOperation : RKObjectRequestOperation

@end
