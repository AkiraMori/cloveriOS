//
//  CLCreateActivityPendingCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "UIColor+CloverAdditions.h"
#import "UIAlertView+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"
#import "CLActivityDetailsPendingCell.h"

@interface CLActivityDetailsPendingCell ()

@property (strong, nonatomic) NSString *requestId;

@end

@implementation CLActivityDetailsPendingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.cancelRequestButton.layer.borderColor  = [UIColor primaryBrandColor].CGColor;
    self.cancelRequestButton.layer.borderWidth  = .5f;
    self.cancelRequestButton.layer.cornerRadius = 3.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        self.requestId = dictionary[@"requestId"];
        
    }
}

- (IBAction)cancelRequest:(id)sender
{
    [UIAlertView showAlertWithTitle:@"Are you sure?"
                            message:@"You're about to cancel this request."
                        cancelTitle:@"Cancel"
                        acceptTitle:@"I'm Sure"
                 cancelButtonAction:nil
                       acceptAction:^{
                           
                           [[CLApiClient sharedInstance] cancelRequestWithId:self.requestId
                                                                successBlock:^(NSArray *result) {
                                                                    
                                                                    [UIAlertView showMessage:nil title:@"Your request was successfully canceled"];
                                                                    
                                                                    DDLogInfo(@"Successfully Cancelled Request with Id: %@", self.requestId);
                                                                    
                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kCLRequestOptionPerformedNotification
                                                                                                                        object:nil];
                                                                    
                                                                } failureBlock:^(NSError *error) {
                                                                    
                                                                    [UIAlertView showErrorMessageWithAcceptAction:^{
                                                                        
                                                                        [self performSelector:@selector(cancelRequest:)
                                                                                   withObject:self.cancelRequestButton];
                                                                        
                                                                    }];
                                                                    
                                                                    DDLogError(@"Error: %@", error.description);
                                                                    
                                                                }];
                           
                       }];
}

@end
