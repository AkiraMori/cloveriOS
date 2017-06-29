//
//  CLResultsTableController.m
//  Partake
//
//  Created by Pablo Episcopo on 3/13/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLResultsTableController.h"

@implementation CLResultsTableController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:@"cell"];
    }
    
    CLActivity *activity = self.filteredActivities[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = activity.name;
    cell.textLabel.font = [UIFont fontWithName:kCLPrimaryBrandFontText
                                          size:17.f];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredActivities.count;
}

- (void)setFilteredActivities:(NSArray *)filteredActivities {
    NSMutableArray *activities = [NSMutableArray array];
    for (CLActivity *activity in filteredActivities) {
        if (activity.name) {
            [activities addObject:activity];
        }
    }
    _filteredActivities = activities;
}

@end
