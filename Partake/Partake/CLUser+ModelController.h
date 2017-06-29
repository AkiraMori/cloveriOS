//
//  CLUser+ModelController.h
//  Partake
//
//  Created by Pablo Episcopo on 2/27/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "CLUser.h"

@interface CLUser (ModelController)

+ (CLUser *)getUserById:(NSString *)userId;
+ (CLUser *)getUserByFacebookId:(NSString *)fbId;



@end
