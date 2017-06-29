//
//  CLActivityTitleCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/14/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLCreateActivityTitleCell.h"
#import "NSDictionary+CloverAdditions.h"

@interface CLCreateActivityTitleCell () <UITextFieldDelegate>

@property (copy, nonatomic) BOOL (^titleValueIndexValueBlock)(NSString *);
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation CLCreateActivityTitleCell

- (void)awakeFromNib
{
    self.titleTextField.autocapitalizationType = UITextAutocorrectionTypeYes;
    self.titleTextField.returnKeyType          = UIReturnKeyDone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        self.titleTextField.text = dictionary[@"title"];
        NSString *type = dictionary[@"type"];
        
        if ([type isEqualToString:@"onboarding"]) {
            self.titleLabel.text = @"Activity Title:";
            self.titleTextField.backgroundColor = [UIColor whiteColor];
            self.titleTextField.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.25f].CGColor;
            self.titleTextField.layer.borderWidth = 1;
            [self.separatorView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.25f]];
        }
        
    }
}

- (void)getTitleValueWithCompletion:(BOOL (^)(NSString *))completion
{
    self.titleValueIndexValueBlock = completion;
}

#pragma mark UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.titleTextField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return self.titleValueIndexValueBlock([textField.text stringByReplacingCharactersInRange:range withString:string]);
}

@end
