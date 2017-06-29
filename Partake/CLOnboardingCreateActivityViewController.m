//
//  CLOnboardingCreateActivityViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 2/23/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLDateHelper.h"
#import "NSDate+DateTools.h"
#import "CLActivityHelper.h"
#import "CLCreateActivityTypeCell.h"
#import "CLCreateActivityTitleCell.h"
#import "CLCreateActivityDetailsCell.h"
#import "CLCreateActivityFiltersInfoCell.h"
#import "CLCreateActivityButtonCell.h"
#import "CLCreateActivityImageCell.h"
#import "UIAlertView+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"
#import "CLOnboardingCreateActivityViewController.h"
#import "UIViewController+CloverAdditions.h"
#import "CLCreateActivityNavigationController.h"
#import "CLCreateActivityFiltersViewController.h"
#import "CLActivityDetailsHomeViewController.h"
#import "CLOnboardingController.h"
#import "CLLocationManagerController.h"

#define kCLActivityTypePlaceholder @"-- Select --"

static NSString * const kCLTypeIdentifier     = @"TypeCell";
static NSString * const kCLTitleIdentifier    = @"TitleCell";
static NSString * const kCLDetailsIdentifier  = @"DetailsCell";
static NSString * const kCLInfoCellIdentifier = @"InfoCell";
static NSString * const kCLButtonCellIdentifier = @"ButtonCell";
static NSString * const kCLImageCellIdentifier = @"ImageCell";

@interface CLOnboardingCreateActivityViewController ()

@property (strong, nonatomic) CLCreateActivityTypeCell        *typeCell;
@property (strong, nonatomic) CLCreateActivityTitleCell       *titleCell;
@property (strong, nonatomic) CLCreateActivityDetailsCell     *detailsCell;
@property (strong, nonatomic) CLCreateActivityFiltersInfoCell *infoCell;
@property (strong, nonatomic) CLCreateActivityButtonCell      *buttonCell;
@property (strong, nonatomic) CLCreateActivityImageCell       *imageCell;

@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) NSMutableArray *activityTypes;

@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;
@property (strong, nonatomic) NSString *activityDetails;

@property (nonatomic) NSInteger activityTypeIndex;

@end

@implementation CLOnboardingCreateActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle          = UITableViewCellSeparatorStyleNone;
    self.tableView.delaysContentTouches    = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableViewContentInsets:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.activityType      = @"Select Type";
    
    self.activityTypes     = [NSMutableArray arrayWithArray:[CLActivityHelper activityTypes]];
    self.activityTitle     = (self.activityTitle)   ? self.activityTitle   : @"";
    self.activityDetails   = (self.activityDetails) ? self.activityDetails : @"";
    
    [self.activityTypes insertObject:kCLActivityTypePlaceholder
                             atIndex:0];
    
    self.activityTypeIndex = ([self.activityType isEqualToString:@"Select Type"]) ? 0 : [self.activityTypes indexOfObject:self.activityType];
    
    [self loadCellNibs];
    
    self.typeCell        = [self.tableView        dequeueReusableCellWithIdentifier:kCLTypeIdentifier];
    self.titleCell       = [self.tableView       dequeueReusableCellWithIdentifier:kCLTitleIdentifier];
    self.detailsCell     = [self.tableView     dequeueReusableCellWithIdentifier:kCLDetailsIdentifier];
    self.infoCell        = [self.tableView    dequeueReusableCellWithIdentifier:kCLInfoCellIdentifier];
    self.buttonCell      = [self.tableView    dequeueReusableCellWithIdentifier:kCLButtonCellIdentifier];
    self.imageCell       = [self.tableView    dequeueReusableCellWithIdentifier:kCLImageCellIdentifier];
    
    
    [self configureCells];
    
    self.cells = [NSMutableArray arrayWithObjects:self.imageCell,
                  self.infoCell,
                  self.titleCell,
                  self.detailsCell,
                  self.buttonCell,
                  nil];
    
    [self.cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (![obj isKindOfClass:[CLCreateActivityFiltersInfoCell class]]) {
            
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(hideKeyboardForInputs)];
            
            [obj addGestureRecognizer:gestureRecognizer];
            
        }
    }];
    
    [self requiredDismissModalButtonWithTitle:@"Cancel"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                              inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Utilities

- (void)loadCellNibs
{
    UINib *typeCellNib    = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityTypeCell        class])
                                           bundle:[NSBundle mainBundle]];
    
    UINib *titleCellNib   = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityTitleCell       class])
                                           bundle:[NSBundle mainBundle]];
    
    UINib *detailsCellNib = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityDetailsCell     class])
                                           bundle:[NSBundle mainBundle]];
    
    UINib *infoCellNib    = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityFiltersInfoCell class])
                                           bundle:[NSBundle mainBundle]];
    
    UINib *buttonCellNib    = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityButtonCell class])
                                           bundle:[NSBundle mainBundle]];
    
    UINib *imageCellNib    = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityImageCell class])
                                             bundle:[NSBundle mainBundle]];
    
    
    [self.tableView registerNib:typeCellNib
         forCellReuseIdentifier:kCLTypeIdentifier];
    
    [self.tableView registerNib:titleCellNib
         forCellReuseIdentifier:kCLTitleIdentifier];
    
    [self.tableView registerNib:detailsCellNib
         forCellReuseIdentifier:kCLDetailsIdentifier];
    
    [self.tableView registerNib:infoCellNib
         forCellReuseIdentifier:kCLInfoCellIdentifier];
    
    [self.tableView registerNib:buttonCellNib
         forCellReuseIdentifier:kCLButtonCellIdentifier];
    
    [self.tableView registerNib:imageCellNib
         forCellReuseIdentifier:kCLImageCellIdentifier];
    
}

- (void)configureCells
{
    [self.infoCell configureCellAppearanceWithData:@{
                                                     @"infoLabel" : @"Type:",
                                                     @"valueLabel": self.activityType,
                                                     @"type"      : @"onboarding"
                                                     }];
    
    self.typeCell.arrayData = self.activityTypes;
    
    [self.typeCell configureCellWithDictionary:@{
                                                 @"index": @(self.activityTypeIndex),
                                                 @"type" : @"onboarding"
                                                 }];
    
    [self.typeCell getPickerIndexValueWithCompletion:^(NSInteger pickerIndex) {
        
        NSString *type         = self.activityTypes[pickerIndex];
        
        self.activityTypeIndex = pickerIndex;
        self.activityType      = type;
        
        [self.infoCell configureCellAppearanceWithData:@{
                                                         @"infoLabel" : @"Type:",
                                                         @"valueLabel": [type isEqualToString:kCLActivityTypePlaceholder] ? @"Select Type" : type,
                                                         @"type"      : @"onboarding"
                                                         }];
        
    }];
    
    [self.titleCell configureCellWithDictionary:@{
                                                  @"title": self.activityTitle,
                                                  @"type" : @"onboarding"
                                                  }];
    
    [self.titleCell getTitleValueWithCompletion:^(NSString *title) {
        
        if (title.length > 60) {
            return NO;
        }
        
        self.activityTitle = title;
        
        return YES;
        
    }];
    
    [self.detailsCell configureCellWithDictionary:@{
                                                    @"details": self.activityDetails,
                                                    @"type"   : @"onboarding"
                                                    }];
    
    [self.detailsCell getDetailsValueWithCompletion:^(NSString *details) {
        
        self.activityDetails = details;
        
    }];
    
    [self.buttonCell.partakeButton addTarget:self action:@selector(partakeTapped) forControlEvents:UIControlEventTouchUpInside];

}

#pragma mark - Actions

- (void)partakeTapped {
    
    [self.view endEditing:YES];
//    CLOnboardingController *onboardingController = (CLOnboardingController *)self.parentViewController;
//    [onboardingController gotoNextPage];
    if ([self isFormValid]) {
        
        [self createActivity];
        
    }
    
}


#pragma mark - Custom methods

- (void)createActivity
{
    
    CLOnboardingController *onboardingController = (CLOnboardingController *)self.parentViewController;
    
    
    [self showProgressHUDWithStatus:@"Generating Activity..."];
    
    NSString *creatorId = [CLApiClient sharedInstance].loggedUser.userId;
    NSString *date = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDate = [[[NSDate date] dateByAddingDays:60] formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *name = self.activityTitle;
    NSString *details = self.activityDetails;
    NSString *type = self.activityType;
    NSString *fromTime = @"Evening";
    NSString *toTime = @"";
    NSString *address = [CLLocationManagerController sharedInstance].currentAddress;
    if (!address) address = @"New York, NY";
    NSString *visibility = @"Everyone";
    NSString *gender = @"both";
    NSNumber *ageFilterFrom = @16;
    NSNumber *ageFilterTo = @55;
    BOOL isAtendeeVisible = YES;
    
    [[CLApiClient sharedInstance] setAuthHeaderWithAccessToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
    
    [[CLApiClient sharedInstance] createActivityWithCreaterId:creatorId
                                                         date:date
                                                      endDate:endDate
                                                         name:name
                                                      details:details
                                                         type:type
                                                     fromTime:fromTime
                                                       toTime:toTime
                                                      address:address
                                                   visibility:visibility
                                                       gender:gender
                                                ageFilterFrom:ageFilterFrom
                                                  ageFilterTo:ageFilterTo
                                             isAtendeeVisible:isAtendeeVisible
                                                 successBlock:^(NSArray *result) {
                                                     
                                                     [self dismissProgressHUD];
                                                     
                                                     [UIAlertView showAlertWithTitle:@"Your activity was successfully created!"
                                                                             message:nil
                                                                         cancelTitle:nil
                                                                         acceptTitle:@"OK"
                                                                  cancelButtonAction:nil
                                                                        acceptAction:^{
                                                                            [onboardingController gotoNextPage];
                                                                        }];
                                                     
                                                 } failureBlock:^(NSError *error) {
                                                     
                                                     [self dismissProgressHUD];
                                                     
                                                     DDLogError(@"Error: %@", error.description);
                                                     
                                                     if ([error.userInfo[NSLocalizedRecoverySuggestionErrorKey] containsString:@"Invalid address"]) {
                                                         
                                                         [UIAlertView showAlertWithTitle:@"Error"
                                                                                 message:@"You entered an invalid address. Please check the address and try again."
                                                                             cancelTitle:nil
                                                                             acceptTitle:@"OK"
                                                                      cancelButtonAction:nil
                                                                            acceptAction:^{
                                                                                [self.navigationController popViewControllerAnimated:YES];
                                                                            }];
                                                         
                                                     } else {
                                                         
                                                         [UIAlertView showErrorMessageWithAcceptAction:^{
                                                             
                                                             [self performSelector:@selector(createActivity)
                                                                        withObject:nil];
                                                             
                                                         }];
                                                         
                                                     }
                                                     
                                                 }];
}

- (void)hideKeyboardForInputs
{
    [self.titleCell.titleTextField    resignFirstResponder];
    [self.detailsCell.detailsTextView resignFirstResponder];
}

- (BOOL)isFormValid
{
    if (([self.activityType isEqualToString:@"Select Type"]) ||
        ([self.activityType isEqualToString:kCLActivityTypePlaceholder])) {
        
        [UIAlertView showMessage:@"Please select activity type."
                           title:@"Missing or Invalid Entry"];
        
        return NO;
        
    }
    
    
    if ([self.activityTitle isEqualToString:@""]) {
        
        [UIAlertView showMessage:@"Please input activity title."
                           title:@"Missing or Invalid Entry"];
        
        return NO;
        
    }
    
    if ([self.activityDetails isEqualToString:@""]) {
        
        [UIAlertView showMessage:@"Please input activity details."
                           title:@"Missing or Invalid Entry"];
        
        return NO;
        
    }
    
    return YES;
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.cells[indexPath.row];
    
    return cell.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.cells[indexPath.row];
    
    cell.selectionStyle   = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSIndexPath *indexPathToModify = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                        inSection:indexPath.section];
    
    [self performSelector:@selector(hideKeyboardForInputs)];
    
    if ([cell isKindOfClass:[CLCreateActivityFiltersInfoCell class]]) {
        
        if (![self.cells containsObject:self.typeCell]) {
            
            [self.cells insertObject:self.typeCell
                             atIndex:indexPathToModify.row];
            
            [self.tableView insertRowsAtIndexPaths:@[indexPathToModify]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
        } else {
            
            [self.cells removeObjectAtIndex:indexPathToModify.row];
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPathToModify]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
    }
}

#pragma mark - Keyboard

- (void)adjustTableViewContentInsets:(NSNotification *)aNotification {
    CGFloat keyboardHeight = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.f, 0.f, keyboardHeight, 0.f);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

@end
