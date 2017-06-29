//
//  CLCreateActivityShowDetailsCell.h
//  Partake
//
//  Created by Maikel on 29/10/15.
//  Copyright © 2015 SCF Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLTableViewCell.h"

@interface CLCreateActivityShowDetailsCell : CLTableViewCell

- (void)getTapActionWithBlock:(void(^)())block;
@end
