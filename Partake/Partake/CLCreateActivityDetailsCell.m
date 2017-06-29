//
//  CLActivityDetailsCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/14/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLConstants.h"
#import "CLCreateActivityDetailsCell.h"
#import "NSDictionary+CloverAdditions.h"

@interface CLCreateActivityDetailsCell () <UITextViewDelegate>

@property (copy, nonatomic) void (^detailsValueIndexValueBlock)(NSString *);

@end

@implementation CLCreateActivityDetailsCell

- (void)awakeFromNib
{
    self.detailsTextView.autocapitalizationType = UITextAutocorrectionTypeYes;
    self.detailsTextView.returnKeyType          = UIReturnKeyDefault;
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(textViewDoneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.detailsTextView.inputAccessoryView = keyboardToolbar;
    
    [super awakeFromNib];
}

- (void)textViewDoneButtonPressed {
    [self.detailsTextView resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        self.detailsTextView.text = dictionary[@"details"];
        
        self.characterCount.text  = [NSString stringWithFormat:@"%li", kCLMaxNoteLength - self.detailsTextView.text.length];
        
        NSString *type = dictionary[@"type"];
        
        if ([type isEqualToString:@"onboarding"]) {
            self.detailsLabel.text = @"Activity Details:";
            self.detailsTextView.backgroundColor = [UIColor whiteColor];
            self.detailsTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.25f].CGColor;
            self.detailsTextView.layer.borderWidth = 1;
        }
        
    }
}

- (void)getDetailsValueWithCompletion:(void (^)(NSString *))completion
{
    self.detailsValueIndexValueBlock = completion;
}

#pragma mark UITextView Delegate Methods

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger len = textView.text.length;
    
    self.characterCount.text = [NSString stringWithFormat:@"%li", kCLMaxNoteLength - len];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length == 0) {
        
        if (textView.text.length != 0) {
            
            self.detailsValueIndexValueBlock([textView.text stringByAppendingString:text]);
            
            return YES;
            
        }
        
    } else if (textView.text.length > kCLMaxNoteLength - 1) {
        
        if ([text isEqualToString:@""]) {
            
            self.detailsValueIndexValueBlock([textView.text stringByAppendingString:text]);
            
            return YES;
            
        }
        
        return NO;
        
    }
    
    self.detailsValueIndexValueBlock([textView.text stringByAppendingString:text]);
    
    return YES;
}

@end
