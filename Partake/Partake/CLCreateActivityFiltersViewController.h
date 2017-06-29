//
//  CLCreateActivityFiltersViewController.h
//  Partake
//
//  Created by Pablo Episcopo on 4/9/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLTableViewController.h"

@interface CLCreateActivityFiltersViewController : CLTableViewController

@property (strong, nonatomic) NSString *viewableBy;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *endDateString;
@property (strong, nonatomic) NSString *timeStartString;
@property (strong, nonatomic) NSString *timeEndString;
@property (strong, nonatomic) NSString *locationHumanAddress;

@property (strong, nonatomic) NSString *timeFrame;

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *timeStart;
@property (strong, nonatomic) NSDate *timeEnd;

@property (nonatomic) NSInteger ageFrom;
@property (nonatomic) NSInteger ageTo;
@property (nonatomic) BOOL      attendeeValue;

@end
