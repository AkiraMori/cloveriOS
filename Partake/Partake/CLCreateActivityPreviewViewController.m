//
//  CLCreateActivityPreviewViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/15/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLActivityHelper.h"
#import "UIView+Positioning.h"
#import "CLActivityDetailsInfoCell.h"
#import "UIAlertView+CloverAdditions.h"
#import "UIViewController+SVProgressHUD.h"
#import "UIViewController+CloverAdditions.h"
#import "CLActivityDetailsDescriptionCell.h"
#import "CLCreateActivityPreviewViewController.h"
#import "CLCreateActivityNavigationController.h"
#import "CLLocationManagerController.h"

#define kCLRowNumberInSection      2
#define kCLRowHeightCellNormal     50.f
#define kCLRowHeightCellNormalInfo 149.f

static NSString * const kCLPreviewInfoCellIdentifier        = @"ActivityDetailsInfo";
static NSString * const kCLPreviewDescriptionCellIdentifier = @"ActivityDetailsDescription";

@interface CLCreateActivityPreviewViewController ()

@property (strong, nonatomic) CLCreateActivityNavigationController *createActivityNavigationController;
@property (strong, nonatomic) NSString *locationHumanAddress;
@end

@implementation CLCreateActivityPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Preview";
    
    self.createActivityNavigationController = (CLCreateActivityNavigationController *)self.navigationController;
    
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Create"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(createActivity:)];
    
    UINib *activityInfoCellNib        = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsInfoCell class])
                                                       bundle:[NSBundle mainBundle]];
    
    UINib *activityDescriptionCellNib = [UINib nibWithNibName:NSStringFromClass([CLActivityDetailsDescriptionCell class])
                                                       bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:activityInfoCellNib        forCellReuseIdentifier:kCLPreviewInfoCellIdentifier];
    [self.tableView registerNib:activityDescriptionCellNib forCellReuseIdentifier:kCLPreviewDescriptionCellIdentifier];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self requiredPopViewControllerBackButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.locationHumanAddress = self.createActivityNavigationController.createActivityFiltersViewController.locationHumanAddress;
    if ([self.locationHumanAddress isEqualToString:@"Current Location"]) {
        self.locationHumanAddress = [CLLocationManagerController sharedInstance].currentAddress;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Utilities

- (IBAction)createActivity:(id)sender
{
    if (!self.createActivityNavigationController.isEditingActivity) {
        
        [self createActivity];
        
    } else {
        
        [self editActivity];
        
    }
}

- (void)createActivity
{
    [self showProgressHUDWithStatus:@"Generating Activity..."];
    
    NSString *fromTime = ([CLActivityHelper isTimeFrame:self.createActivityNavigationController.createActivityFiltersViewController.timeFrame]) ? self.createActivityNavigationController.createActivityFiltersViewController.timeFrame : self.createActivityNavigationController.createActivityFiltersViewController.timeStartString;
    
    NSString *toTime   = ([CLActivityHelper isTimeFrame:self.createActivityNavigationController.createActivityFiltersViewController.timeFrame]) ? @"" : self.createActivityNavigationController.createActivityFiltersViewController.timeEndString;
    
    [[CLApiClient sharedInstance] createActivityWithCreaterId:[CLApiClient sharedInstance].loggedUser.userId
                                                         date:self.createActivityNavigationController.createActivityFiltersViewController.dateString
                                                      endDate:self.createActivityNavigationController.createActivityFiltersViewController.endDateString
                                                         name:self.createActivityNavigationController.createActivityViewController.activityTitle
                                                      details:self.createActivityNavigationController.createActivityViewController.activityDetails
                                                         type:self.createActivityNavigationController.createActivityViewController.activityType
                                                     fromTime:fromTime
                                                       toTime:toTime
                                                      address:self.locationHumanAddress
                                                   visibility:self.createActivityNavigationController.createActivityFiltersViewController.viewableBy
                                                       gender:self.createActivityNavigationController.createActivityFiltersViewController.gender
                                                ageFilterFrom:@(self.createActivityNavigationController.createActivityFiltersViewController.ageFrom)
                                                  ageFilterTo:@(self.createActivityNavigationController.createActivityFiltersViewController.ageTo)
                                             isAtendeeVisible:self.createActivityNavigationController.createActivityFiltersViewController.attendeeValue
                                                 successBlock:^(NSArray *result) {
                                                     
                                                     [self dismissProgressHUD];
                                                     
                                                     [[[UIAlertView alloc] initWithTitle:@"Your activity was successfully created!"
                                                                                 message:nil
                                                                                delegate:self
                                                                       cancelButtonTitle:@"Ok"
                                                                       otherButtonTitles:nil]
                                                      show];
                                                     
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
                                                             
                                                             [self performSelector:@selector(createActivity:)
                                                                        withObject:nil];
                                                             
                                                         }];
                                                         
                                                     }
                                                     
                                                 }];
}

- (void)editActivity
{
    [self showProgressHUDWithStatus:@"Editing Activity..."];
    
    NSString *fromTime = ([CLActivityHelper isTimeFrame:self.createActivityNavigationController.createActivityFiltersViewController.timeFrame]) ? self.createActivityNavigationController.createActivityFiltersViewController.timeFrame : self.createActivityNavigationController.createActivityFiltersViewController.timeStartString;
    
    NSString *toTime   = ([CLActivityHelper isTimeFrame:self.createActivityNavigationController.createActivityFiltersViewController.timeFrame]) ? @"" : self.createActivityNavigationController.createActivityFiltersViewController.timeEndString;
    
    [[CLApiClient sharedInstance] editActivityWithCreaterId:[CLApiClient sharedInstance].loggedUser.userId
                                                       date:self.createActivityNavigationController.createActivityFiltersViewController.dateString
                                                    endDate:self.createActivityNavigationController.createActivityFiltersViewController.endDateString
                                                       name:self.createActivityNavigationController.createActivityViewController.activityTitle
                                                    details:self.createActivityNavigationController.createActivityViewController.activityDetails
                                                       type:self.createActivityNavigationController.createActivityViewController.activityType
                                                   fromTime:fromTime
                                                     toTime:toTime
                                                    address:self.locationHumanAddress
                                                 visibility:self.createActivityNavigationController.createActivityFiltersViewController.viewableBy
                                                     gender:self.createActivityNavigationController.createActivityFiltersViewController.gender
                                              ageFilterFrom:@(self.createActivityNavigationController.createActivityFiltersViewController.ageFrom)
                                                ageFilterTo:@(self.createActivityNavigationController.createActivityFiltersViewController.ageTo)
                                           isAtendeeVisible:self.createActivityNavigationController.createActivityFiltersViewController.attendeeValue
                                              addressEdited:YES
                                                 activityId:self.activityId
                                                 locationId:self.locationId
                                               successBlock:^(NSArray *result) {
                                                   
                                                   [self dismissProgressHUD];
                                                   
                                                   [[[UIAlertView alloc] initWithTitle:@"Your activity was successfully updated."
                                                                               message:nil
                                                                              delegate:self
                                                                     cancelButtonTitle:@"Ok"
                                                                     otherButtonTitles:nil]
                                                    show];
                                                   
                                               } failureBlock:^(NSError *error) {
                                                   
                                                   [self dismissProgressHUD];
                                                   
                                                   DDLogError(@"Error: %@", error.description);
                                                   
                                                   [UIAlertView showErrorMessageWithAcceptAction:^{
                                                       
                                                       [self performSelector:@selector(createActivity:)
                                                                  withObject:nil];
                                                       
                                                   }];
                                                   
                                               }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

- (NSInteger)calculateHeightForDescription
{
    CGFloat marginValue = 40.f;
    
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    
    UIFont *font = [UIFont fontWithName:kCLPrimaryBrandFontText
                                   size:12.f];
    
    CLLabel *calculationView = [CLLabel new];
    calculationView.text     = self.createActivityNavigationController.createActivityViewController.activityDetails;
    calculationView.font     = font;
    
    CGRect textRect = [calculationView.text boundingRectWithSize:CGSizeMake(self.tableView.width - 14.f, MAXFLOAT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:font}
                                                         context:ctx];
    
    return textRect.size.height + marginValue;
}

- (UIView *)viewForHeaderFooter
{
    UIView *sectionSpace         = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width, 20.f)];
    
    sectionSpace.backgroundColor = [UIColor redColor];
    
    return sectionSpace;
}

#pragma mark - UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"CellIdentifier";
    
    UITableViewCell                  *cell                   = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CLActivityDetailsInfoCell        *cellDetailsInfo        = [self.tableView dequeueReusableCellWithIdentifier:kCLPreviewInfoCellIdentifier];
    CLActivityDetailsDescriptionCell *cellDetailsDescription = [self.tableView dequeueReusableCellWithIdentifier:kCLPreviewDescriptionCellIdentifier];
    
    cellDetailsInfo.selectionStyle        = UITableViewCellSelectionStyleNone;
    cellDetailsDescription.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        
        NSString *fromTime = ([CLActivityHelper isTimeFrame:self.createActivityNavigationController.createActivityFiltersViewController.timeFrame]) ? self.createActivityNavigationController.createActivityFiltersViewController.timeFrame : self.createActivityNavigationController.createActivityFiltersViewController.timeStartString;
        
        NSString *toTime   = ([CLActivityHelper isTimeFrame:self.createActivityNavigationController.createActivityFiltersViewController.timeFrame]) ? @"" : self.createActivityNavigationController.createActivityFiltersViewController.timeEndString;
        
        NSDictionary *activityParams = @{
                                         @"type"        : self.createActivityNavigationController.createActivityViewController.activityType,
                                         @"location"    : self.locationHumanAddress,
                                         @"name"        : self.createActivityNavigationController.createActivityViewController.activityTitle,
                                         @"activityDate": self.createActivityNavigationController.createActivityFiltersViewController.dateString,
                                         @"activityEndDate": self.createActivityNavigationController.createActivityFiltersViewController.endDateString,
                                         @"fromTime"    : fromTime,
                                         @"toTime"      : toTime,
                                         @"date"        : self.createActivityNavigationController.createActivityFiltersViewController.date,
                                         };
        
        [cellDetailsInfo configureCellWithDictionary:@{@"activityPreview": activityParams}];
        
        return cellDetailsInfo;
        
    } else if (indexPath.row == 1) {
        
        [cellDetailsDescription configureCellWithDictionary:@{@"activityDetails": self.createActivityNavigationController.createActivityViewController.activityDetails}];
        
        return cellDetailsDescription;
        
    }
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:cellIdentifier];
        
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self viewForHeaderFooter];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self viewForHeaderFooter];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kCLRowNumberInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        return kCLRowHeightCellNormalInfo;
        
    } else if (indexPath.row == 1) {
        
        return [self calculateHeightForDescription];
        
    }
    
    return kCLRowHeightCellNormal;
}

@end
