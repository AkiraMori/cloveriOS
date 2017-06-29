//
//  CLCreateActivityReceiveCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/24/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "UIColor+CloverAdditions.h"
#import "UIAlertView+CloverAdditions.h"
#import "NSDictionary+CloverAdditions.h"
#import "CLActivityDetailsReceivedCell.h"

@interface CLActivityDetailsReceivedCell ()

@property (strong, nonatomic) NSString *requestId;
@property (copy, nonatomic) void(^startChatBlock)();

@end

@implementation CLActivityDetailsReceivedCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    CGColorRef borderColor  = [UIColor primaryBrandColor].CGColor;
    CGFloat    borderWidth  = .5f;
    CGFloat    cornerRadius = 3.f;
    
    self.acceptButton.layer.borderColor  = borderColor;
    self.acceptButton.layer.borderWidth  = borderWidth;
    self.acceptButton.layer.cornerRadius = cornerRadius;
    
    self.denyButton.layer.borderColor    = borderColor;
    self.denyButton.layer.borderWidth    = borderWidth;
    self.denyButton.layer.cornerRadius   = cornerRadius;
    
    self.chatButton.layer.borderColor    = borderColor;
    self.chatButton.layer.borderWidth    = borderWidth;
    self.chatButton.layer.cornerRadius   = cornerRadius;
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

- (IBAction)acceptRequest:(id)sender
{
    [UIAlertView showAlertWithTitle:@"Are you sure?"
                            message:@"You're about to accept this request."
                        cancelTitle:@"Cancel"
                        acceptTitle:@"I'm Sure"
                 cancelButtonAction:nil
                       acceptAction:^{
                           
                           [[CLApiClient sharedInstance] acceptRequestWithId:self.requestId
                                                                successBlock:^(NSArray *result) {
                                                                    
                                                                    [UIAlertView showMessage:@"Successfully Acccepted"];
                                                                    
                                                                    DDLogInfo(@"Successfully Accepted Request with Id: %@", self.requestId);
                                                                    
                                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kCLRequestOptionPerformedNotification
                                                                                                                        object:nil];
                                                                    
                                                                } failureBlock:^(NSError *error) {
                                                                    
                                                                    [UIAlertView showErrorMessageWithAcceptAction:^{
                                                                        
                                                                        [self performSelector:@selector(acceptRequest:)
                                                                                   withObject:self.acceptButton];
                                                                        
                                                                    }];
                                                                    
                                                                    DDLogError(@"Error: %@", error.description);
                                                                    
                                                                }];
                           
                       }];
}

- (IBAction)denyRequest:(id)sender
{
    [UIAlertView showAlertWithTitle:@"Are you sure?"
                            message:@"You're about to deny this request."
                        cancelTitle:@"Cancel"
                        acceptTitle:@"I'm Sure"
                 cancelButtonAction:nil
                       acceptAction:^{
                           
                           [[CLApiClient sharedInstance] denyRequestWithId:self.requestId
                                                              successBlock:^(NSArray *result) {
                                                                  
                                                                  [UIAlertView showMessage:nil title:@"This request was successfully declined"];
                                                                  
                                                                  DDLogInfo(@"Successfully Denied Request with Id: %@", self.requestId);
                                                                  
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kCLRequestOptionPerformedNotification
                                                                                                                      object:nil];
                                                                  
                                                              } failureBlock:^(NSError *error) {
                                                                  
                                                                  [UIAlertView showErrorMessageWithAcceptAction:^{
                                                                      
                                                                      [self performSelector:@selector(denyRequest:)
                                                                                 withObject:self.denyButton];
                                                                      
                                                                  }];
                                                                  
                                                                  DDLogError(@"Error: %@", error.description);
                                                                  
                                                              }];
                           
                       }];
}

- (IBAction)startChat:(id)sender
{
    if (_startChatBlock) {
        _startChatBlock();
    }
}

- (void)setOnStartChat:(void(^)())startChat {
    _startChatBlock = startChat;
}

@end
