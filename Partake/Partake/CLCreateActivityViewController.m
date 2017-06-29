//
//  CLCreateActivityViewController.m
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
#import "UIAlertView+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"
#import "CLCreateActivityViewController.h"
#import "CLCreateActivityFiltersInfoCell.h"
#import "UIViewController+CloverAdditions.h"
#import "CLCreateActivityNavigationController.h"
#import "CLCreateActivityFiltersViewController.h"
#import "CLCreateActivityShowDetailsCell.h"
#import "CLActivityDetailsHomeViewController.h"

#define kCLHeaderFooterHeight      20.f
#define kCLActivityTypePlaceholder @"-- Select --"

static NSString * const kCLTypeIdentifier     = @"TypeCell";
static NSString * const kCLTitleIdentifier    = @"TitleCell";
static NSString * const kCLDetailsIdentifier  = @"DetailsCell";
static NSString * const kCLInfoCellIdentifier = @"InfoCell";
static NSString * const kCLShowDetailsIdentifier = @"ShowDetailsCell";

@interface CLCreateActivityViewController ()

@property (strong, nonatomic) CLCreateActivityTypeCell        *typeCell;
@property (strong, nonatomic) CLCreateActivityTitleCell       *titleCell;
@property (strong, nonatomic) CLCreateActivityDetailsCell     *detailsCell;
@property (strong, nonatomic) CLCreateActivityFiltersInfoCell *infoCell;
@property (strong, nonatomic) CLCreateActivityShowDetailsCell *showDetailsCell;

@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) NSMutableArray *activityTypes;

@property (nonatomic) NSInteger activityTypeIndex;

@end

@implementation CLCreateActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Create Activity";
    
    self.tableView.separatorStyle          = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(validateBeforeSegue:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableViewContentInsets:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.activityType      = (self.activityType)    ? self.activityType    : @"Select Type";
    self.activityTitle     = (self.activityTitle)   ? self.activityTitle   : @"";
    self.activityDetails   = (self.activityDetails) ? self.activityDetails : @"";
    
    self.activityTypes     = [NSMutableArray arrayWithArray:[CLActivityHelper activityTypes]];
    
    [self.activityTypes insertObject:kCLActivityTypePlaceholder
                             atIndex:0];
    
    self.activityTypeIndex = ([self.activityType isEqualToString:@"Select Type"]) ? 0 : [self.activityTypes indexOfObject:self.activityType];
    
    [self loadCellNibs];
    
    self.typeCell        = [self.tableView        dequeueReusableCellWithIdentifier:kCLTypeIdentifier];
    self.titleCell       = [self.tableView       dequeueReusableCellWithIdentifier:kCLTitleIdentifier];
    self.detailsCell     = [self.tableView     dequeueReusableCellWithIdentifier:kCLDetailsIdentifier];
    self.infoCell        = [self.tableView    dequeueReusableCellWithIdentifier:kCLInfoCellIdentifier];
    
    if (((CLCreateActivityNavigationController *)self.navigationController).createActivityPreviewViewController.activityId.length) {
        self.showDetailsCell = [self.tableView dequeueReusableCellWithIdentifier:kCLShowDetailsIdentifier];
    }
    
    [self configureCells];
    
    self.cells = [NSMutableArray arrayWithObjects:self.infoCell,
                  self.titleCell,
                  self.detailsCell,
                  self.showDetailsCell,
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
    
    UINib *showCellNib    = [UINib nibWithNibName:NSStringFromClass([CLCreateActivityShowDetailsCell class])
                                           bundle:[NSBundle mainBundle]];
    
    [self.tableView registerNib:typeCellNib
         forCellReuseIdentifier:kCLTypeIdentifier];
    
    [self.tableView registerNib:titleCellNib
         forCellReuseIdentifier:kCLTitleIdentifier];
    
    [self.tableView registerNib:detailsCellNib
         forCellReuseIdentifier:kCLDetailsIdentifier];
    
    [self.tableView registerNib:infoCellNib
         forCellReuseIdentifier:kCLInfoCellIdentifier];
    
    [self.tableView registerNib:showCellNib
         forCellReuseIdentifier:kCLShowDetailsIdentifier];
}

- (void)configureCells
{
    [self.infoCell configureCellAppearanceWithData:@{
                                                     @"infoLabel" : @"Type:",
                                                     @"valueLabel": self.activityType
                                                     }];
    
    self.typeCell.arrayData = self.activityTypes;
    
    [self.typeCell configureCellWithDictionary:@{@"index": @(self.activityTypeIndex)}];
    
    [self.typeCell getPickerIndexValueWithCompletion:^(NSInteger pickerIndex) {
        
        NSString *type         = self.activityTypes[pickerIndex];
        
        self.activityTypeIndex = pickerIndex;
        self.activityType      = type;
        
        [self.infoCell configureCellAppearanceWithData:@{
                                                         @"infoLabel" : @"Type:",
                                                         @"valueLabel": [type isEqualToString:kCLActivityTypePlaceholder] ? @"Select Type" : type
                                                         }];
        
    }];
    
    [self.titleCell configureCellWithDictionary:@{
                                                  @"title": self.activityTitle
                                                  }];
    
    [self.titleCell getTitleValueWithCompletion:^(NSString *title) {

        if (title.length > 60) {
            return NO;
        }
        
        self.activityTitle = title;
        
        return YES;
        
    }];
    
    [self.detailsCell configureCellWithDictionary:@{@"details": self.activityDetails}];
    
    [self.detailsCell getDetailsValueWithCompletion:^(NSString *details) {
        
        self.activityDetails = details;
        
    }];
    
    [self.showDetailsCell getTapActionWithBlock:^{
        NSLog(@"Tap action!!!");
        
        CLActivityDetailsHomeViewController *detailsVC = [[UIStoryboard storyboardWithName:@"CLHomeViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"CLActivityDetailsViewController"];
        detailsVC.activityId = ((CLCreateActivityNavigationController *)self.navigationController).createActivityPreviewViewController.activityId;
        [self.navigationController pushViewController:detailsVC animated:YES];
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

- (void)validateBeforeSegue:(id)sender
{
    if ([self isFormValid]) {
        
        [self performSelector:@selector(hideKeyboardForInputs)];
        
        CLCreateActivityFiltersViewController *createActivityFiltersViewController = ((CLCreateActivityNavigationController *)self.navigationController).createActivityFiltersViewController;
        
        [self.navigationController pushViewController:createActivityFiltersViewController
                                             animated:YES];
        
    }
}

- (UIView *)viewForHeaderFooter
{
    UIView *sectionSpace         = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width, self.tableView.height)];
    
    sectionSpace.backgroundColor = [UIColor clearColor];
    
    return sectionSpace;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kCLHeaderFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kCLHeaderFooterHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self viewForHeaderFooter];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self viewForHeaderFooter];
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
