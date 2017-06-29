//
//  CLLoggedUser.m
//  Partake
//
//  Created by Pablo Episcopo on 4/7/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLLoggedUser.h"

NSString * const kCLLoggedUserKey   = @"CLLoggedUser";
NSString * const kCLUserIdKey       = @"CLUserId";
NSString * const kCLFbUserIdKey     = @"CLFbUserId";
NSString * const kCLFbUserTokenKey  = @"CLFbUserToken";
NSString * const kCLFirstNameKey    = @"CLFirstName";
NSString * const kCLLastNameKey     = @"CLLastName";
NSString * const kCLIsFirstTimeKey  = @"CLIsFirstTime";
NSString * const kCLLoggedInDateKey = @"CLLoggedInDate";
NSString * const kCLGenderKey       = @"CLGender";
NSString * const kCLAgeKey          = @"CLAge";
NSString * const kCLPicturesKey     = @"CLPictures";

NSString * const kCLDefaultAgeFromKey       = @"CLDefaultAgeFrom";
NSString * const kCLDefaultAgeToKey         = @"CLDefaultAgeTo";
NSString * const kCLDefaultCreatedByKey     = @"CLDefaultCreatedBy";
NSString * const kCLDefaultDistanceLimitKey = @"CLDefaultDistanceLimit";

@interface CLLoggedUser ()

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *fbUserId;
@property (nonatomic, strong) NSString *fbUserToken;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *loggedInDateString;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSArray  *pictures;

@property (nonatomic, strong) NSDate   *loggedInDate;
@property (nonatomic)         BOOL     isFirstTime;
@end

@implementation CLLoggedUser

+ (CLLoggedUser *)loggedUserFromDisk
{
    NSData  *arrayData = [[NSUserDefaults    standardUserDefaults] objectForKey:kCLLoggedUserKey];
    NSArray *array     =  [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    
    return [array firstObject];
}

- (instancetype)initWithUserId:(NSString *)userId
{
    CLUser *storedUser;
    
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
        
        storedUser = [array firstObject];
        
    }
    
    self = [super init];
    
    if (self) {
        
        self.userId         = storedUser.userId;
        self.fbUserId       = storedUser.fbUserId;
        self.fbUserToken    = storedUser.fbUserToken;
        self.firstName      = storedUser.firstName;
        self.lastName       = storedUser.lastName;
        self.age            = storedUser.age;
        self.gender         = storedUser.gender;
        self.loggedInDate   = [NSDate date];
        self.pictures       = storedUser.pictures;
        
        self.defaultActivitiesAgeFrom   = storedUser.defaultActivitiesAgeFrom;
        self.defaultActivitiesAgeTo     = storedUser.defaultActivitiesAgeTo;
        self.defaultActivitiesCreatedBy = storedUser.defaultActivitiesCreatedBy;
        self.defaultLimitSearchResults  = storedUser.defaultLimitSearchResults;
    }
    
    return self;
}

- (void)setLoggedInDate:(NSDate *)loggedInDate
{
    [self willChangeValueForKey:@"loggedInDate"];
    
    self -> _loggedInDate = loggedInDate;
    
    [self didChangeValueForKey:@"loggedInDate"];
}

- (NSString *)loggedInDateString
{
    if (!self -> _loggedInDateString) {
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        
        self -> _loggedInDateString = [dateFormatter stringFromDate:self.loggedInDate];
        
    }
    
    return self -> _loggedInDateString;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (!self) {
        
        return nil;
        
    }
    
    self.userId       = [aDecoder  decodeObjectForKey:kCLUserIdKey];
    self.fbUserId     = [aDecoder  decodeObjectForKey:kCLFbUserIdKey];
    self.fbUserToken  = [aDecoder  decodeObjectForKey:kCLFbUserTokenKey];
    self.firstName    = [aDecoder  decodeObjectForKey:kCLFirstNameKey];
    self.lastName     = [aDecoder  decodeObjectForKey:kCLLastNameKey];
    self.age          = [aDecoder  decodeObjectForKey:kCLAgeKey];
    self.gender       = [aDecoder  decodeObjectForKey:kCLGenderKey];
    self.isFirstTime  = [[aDecoder decodeObjectForKey:kCLIsFirstTimeKey] boolValue];
    self.loggedInDate = [aDecoder  decodeObjectForKey:kCLLoggedInDateKey];
    self.pictures     = [aDecoder  decodeObjectForKey:kCLPicturesKey];
    
    self.defaultActivitiesAgeFrom   = [aDecoder decodeObjectForKey:kCLDefaultAgeFromKey];
    self.defaultActivitiesAgeTo     = [aDecoder decodeObjectForKey:kCLDefaultAgeToKey];
    self.defaultActivitiesCreatedBy = [aDecoder decodeObjectForKey:kCLDefaultCreatedByKey];
    self.defaultLimitSearchResults  = [aDecoder decodeObjectForKey:kCLDefaultDistanceLimitKey];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSString *isFirstTime = [NSString stringWithFormat:@"%i", self.isFirstTime];
    
    [aCoder encodeObject:self.userId       forKey:kCLUserIdKey];
    [aCoder encodeObject:self.fbUserId     forKey:kCLFbUserIdKey];
    [aCoder encodeObject:self.fbUserToken  forKey:kCLFbUserTokenKey];
    [aCoder encodeObject:self.firstName    forKey:kCLFirstNameKey];
    [aCoder encodeObject:self.lastName     forKey:kCLLastNameKey];
    [aCoder encodeObject:self.age          forKey:kCLAgeKey];
    [aCoder encodeObject:self.gender       forKey:kCLGenderKey];
    [aCoder encodeObject:isFirstTime       forKey:kCLIsFirstTimeKey];
    [aCoder encodeObject:self.loggedInDate forKey:kCLLoggedInDateKey];
    [aCoder encodeObject:self.pictures     forKey:kCLPicturesKey];
    
    [aCoder encodeObject:self.defaultActivitiesAgeFrom      forKey:kCLDefaultAgeFromKey];
    [aCoder encodeObject:self.defaultActivitiesAgeTo        forKey:kCLDefaultAgeToKey];
    [aCoder encodeObject:self.defaultActivitiesCreatedBy    forKey:kCLDefaultCreatedByKey];
    [aCoder encodeObject:self.defaultLimitSearchResults     forKey:kCLDefaultDistanceLimitKey];
}

- (void)saveToDisk
{
    NSData *loggedUserData = [NSKeyedArchiver archivedDataWithRootObject:@[self]];
    
    [[NSUserDefaults standardUserDefaults] setObject:loggedUserData forKey:kCLLoggedUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeFromDisk
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCLLoggedUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationCoordinate2D)lastLocation
{
    NSDictionary *userLocation  = self.locationsArray.lastObject;
    
    CLLocationDegrees latitude  = [userLocation[@"latitude"]  floatValue];
    CLLocationDegrees longitude = [userLocation[@"longitude"] floatValue];
    
    return CLLocationCoordinate2DMake(latitude, longitude);
}

@end
