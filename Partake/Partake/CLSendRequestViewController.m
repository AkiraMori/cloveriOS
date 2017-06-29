//
//  CLSendRequestViewController.m
//  Partake
//
//  Created by Pablo Epíscopo on 4/3/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "UIAlertView+CloverAdditions.h"
#import "CLSendRequestViewController.h"
#import "UIViewController+CloverAdditions.h"

@interface CLSendRequestViewController () <UITextViewDelegate>

@property (strong, nonatomic) id keyboardShowNotification;

@property (weak,   nonatomic) IBOutlet UITextView *noteTextView;
@property (weak,   nonatomic) IBOutlet UILabel    *characterCount;

@property (strong, nonatomic)          NSString   *note;

@property (copy, nonatomic) void (^completionBlock)(BOOL);

@end

@implementation CLSendRequestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Send Request";
    
    [self requiredDismissModalButtonWithTitle:@"Cancel"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(sendRequest:)];
    
    self.noteTextView.layer.cornerRadius = 3.f;
    self.characterCount.text             = [NSString stringWithFormat:@"%li", kCLMaxNoteLength - self.noteTextView.text.length];
    
//    __weak CLSendRequestViewController *weakSelf = self;
    
//    self.keyboardShowNotification = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification
//                                                                                      object:nil
//                                                                                       queue:[NSOperationQueue mainQueue]
//                                                                                  usingBlock:^(NSNotification *aNotification) {
//                                                                                      
//                                                                                          CGFloat keyboardHeight = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//                                                                                          UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.f, 0.f, keyboardHeight, 0.f);
//                                                                                          weakSelf.scrollView.contentInset = contentInsets;
//                                                                                          weakSelf.tableView.scrollIndicatorInsets = contentInsets;
//                                                                                  }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.noteTextView becomeFirstResponder];
}

- (void)sendRequest:(id)sender
{
    if (![self isValidateNote]) {
        
        [UIAlertView showMessage:@"Please add some note before send the request."
                           title:@"Empty Note"];
        
        return;
        
    }
    
    NSAssert(self.activity, @"Activity parameter could not be nil.");
    NSAssert(self.note,     @"Note parameter could not be nil."    );
    
    [[CLApiClient sharedInstance] postRequestWithActivityId:self.activity.activityId
                                                requesterId:[CLApiClient sharedInstance].loggedUser.fbUserId
                                                       note:self.note
                                        activityCreatorFbId:self.activity.user.fbUserId
                                               successBlock:^(NSArray *result) {
                                                   
                                                   DDLogInfo(@"Request successfully sent.");
                                                   
                                                   NSString *title = [NSString stringWithFormat:@"Your request to %@ was successfully sent.", self.activity.user.firstName];
                                                   
                                                   [[[UIAlertView alloc] initWithTitle:title
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil]
                                                    show];
                                                   
                                                   self.completionBlock(NO);
                                                   
                                                   [self dismissViewControllerAnimated:YES
                                                                            completion:nil];
                                                   
                                               } failureBlock:^(NSError *error) {
                                                   
                                                   DDLogError(@"Requesting fail with error: %@.", error.description);
                                                   
                                                   [UIAlertView showErrorMessageWithAcceptAction:^{
                                                      
                                                       [self performSelector:@selector(sendRequest:)
                                                                  withObject:nil];
                                                       
                                                   }];
                                               }];
}

- (void)updateBarButtonWithCompletion:(void (^)(BOOL flag))completion
{
    self.completionBlock = completion;
}

- (BOOL)isValidateNote
{
    if (self.noteTextView.text.length > 0) {
        
        self.note = self.noteTextView.text;
        
        return YES;
        
    }
    
    return NO;
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger len = self.noteTextView.text.length;
    
    self.characterCount.text = [NSString stringWithFormat:@"%li", kCLMaxNoteLength - len];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.noteTextView.text.length == 0) {
        
        if (self.noteTextView.text.length != 0) {
            
            return YES;
            
        }
        
    } else if (self.noteTextView.text.length > kCLMaxNoteLength - 1) {
        
        if ([text isEqualToString:@""]) {
            
            return YES;
            
        }
        
        return NO;
        
    }
    
    return YES;
}

@end
