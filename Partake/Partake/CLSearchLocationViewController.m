//
//  CLSearchLocationViewController.m
//  Partake
//
//  Created by Pablo Episcopo on 4/28/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLSearchLocationViewController.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "UIViewController+CloverAdditions.h"

static NSString * const kCLSearchLocationCellIdentifier = @"SearchLocationCell";

@interface CLSearchLocationViewController ()

@property (copy, nonatomic) void (^locationValueBlock)(NSString *);

@property (strong, nonatomic) UISearchController   *searchController;
@property (weak,   nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *results;

@end

@implementation CLSearchLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Choose a location";
    
    self.searchController                                  = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate                         = self;
    self.searchController.searchResultsUpdater             = self;
    self.searchController.searchBar.delegate               = self;
    self.searchController.searchBar.searchBarStyle         = UISearchBarStyleMinimal;
    self.searchController.searchBar.placeholder            = @"Search";
    self.searchController.searchBar.tintColor              = [UIColor standardTextColor];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    [self.searchController.searchBar sizeToFit];
    
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView  = self.searchController.searchBar;
    
    [self requiredDismissModalButtonWithTitle:@"Cancel"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self presentViewController:self.searchController
//                       animated:YES
//                     completion:nil];
    
    [self.searchController becomeFirstResponder];
}

#pragma mark - Utilities

- (void)getLocationValueWithCompletion:(void (^)(NSString *))completion
{
    self.locationValueBlock = completion;
}

- (void)searchControllerStateWithFlag:(BOOL)flag
{
    [[UIApplication sharedApplication] setStatusBarStyle:(flag) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent
                                                animated:YES];
    
    self.navigationController.navigationBar.translucent = flag;
    
    [self.searchController.searchBar setSearchBarStyle:(flag)   ? UISearchBarStyleDefault : UISearchBarStyleMinimal];
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self searchControllerStateWithFlag:NO];
    
    [self.searchController dismissViewControllerAnimated:YES
                                              completion:nil];
}

#pragma mark - UISearchController Delegate Methods

- (void)willPresentSearchController:(UISearchController *)searchController
{
    [self searchControllerStateWithFlag:YES];
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    [self searchControllerStateWithFlag:NO];
}

#pragma mark - UISearchResultsUpdating Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    
    SPGooglePlacesAutocompleteQuery *query = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:@"AIzaSyBnalCleWYv1DpfF3NQaTwsbbWGXEX-5AU"]; // kCLGoogleApiKey];
    
    query.input    = searchString;
    query.language = @"en";
    query.sensor   = YES;
    query.types    = SPPlaceTypeGeocode;
    query.location = [[CLApiClient sharedInstance].loggedUser lastLocation];
    
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        
        if (error) {
            
            [UIAlertView showMessage:@"Oh no! Something went wrong!"
                               title:@"Sorry about that!"];
            
            DDLogError(@"%@", error.description);
            
            return;
            
        }
        
        if (places.count > 0) {
            
            self.results = places;
            
            [self.tableView reloadData];
            
        }
        
    }];
}

#pragma mark - UITableView DataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCLSearchLocationCellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:kCLSearchLocationCellIdentifier];
        
    }
    
    SPGooglePlacesAutocompletePlace *place = self.results[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = place.name;
    cell.textLabel.font = [UIFont fontWithName:kCLPrimaryBrandFontText
                                          size:17.f];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
    
    if (indexPath.row <= self.results.count) {
        
        SPGooglePlacesAutocompletePlace *place = self.results[indexPath.row];
        
        self.locationValueBlock(place.name);
        
        [self searchControllerStateWithFlag:NO];
        
        [self.searchController dismissViewControllerAnimated:YES
                                                  completion:nil];
        
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        
    }
}

@end
