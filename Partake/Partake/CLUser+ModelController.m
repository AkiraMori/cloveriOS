//
//  CLUser+ModelController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/27/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLDateHelper.h"
#import "CLUser+ModelController.h"
#import "CLRequest+ModelController.h"
#import "NSDate+DateTools.h"

@implementation CLUser (ModelController)

#pragma mark - Private Methods

- (instancetype)initWithFacebookUser:(id)facebookUser
{
    NSManagedObjectContext *context = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                              inManagedObjectContext:context];
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    
    if (self) {
        
        NSDate *dateOfBirth = [CLDateHelper dateFromStringDate:facebookUser[@"birthday"]
                                                     formatter:kCLDateFormatterMonthDayYear];
        
        NSNumber *age       = @([dateOfBirth yearsAgo]);
        
        self.fbUserId    = facebookUser[@"id"];
        self.fbUserToken = [[FBSDKAccessToken
                            currentAccessToken] tokenString];
        self.firstName   = facebookUser[@"first_name"];
        self.lastName    = facebookUser[@"last_name"];
        self.gender      = facebookUser[@"gender"];
        self.email       = facebookUser[@"email"];
        self.age         = age;
        
    }
    
    return self;
}

+ (CLUser *)getUserById:(NSString *)userId
{
    NSManagedObjectContext *moc     = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    NSFetchRequest         *request = [NSFetchRequest new];
    
    NSEntityDescription    *entity  = [NSEntityDescription entityForName:@"CLUser"
                                                  inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId ==[c] %@", userId];
    
    [request    setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *array = [moc executeFetchRequest:request
                                        error:&error];
    
    if (array != nil && array.count > 0) {
        return [array firstObject];
    }
    
    return nil;
}

+ (CLUser *)getUserByFacebookId:(NSString *)fbId
{
    NSManagedObjectContext *moc     = [CLDatabaseManager sharedInstance].mainQueuemanagedObjectContext;
    
    NSFetchRequest         *request = [NSFetchRequest new];
    
    NSEntityDescription    *entity  = [NSEntityDescription entityForName:@"CLUser"
                                                  inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbUserId ==[c] %@", fbId];
    
    [request    setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error;
    
    NSArray *array = [moc executeFetchRequest:request
                                        error:&error];
    
    if (array != nil && array.count > 0) {
        return [array firstObject];
    }
    
    return nil;
}

@end
