//
//  CLProfileBioCell.m
//  Partake
//
//  Created by Pablo Episcopo on 4/30/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLProfileBioCell.h"
#import "CLTextView.h"


@interface CLProfileBioCell () <UITextViewDelegate>

@property (assign, nonatomic) BOOL editable;

@property (weak, nonatomic) IBOutlet CLTextView *tvAboutMe;

@property (copy, nonatomic) BOOL (^aboutMeChangedBlock)(NSString *);

@end


@implementation CLProfileBioCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    _tvAboutMe.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


#pragma mark - CLCellConfigurationProtocol Delegate Methods

- (void)configureCellAppearanceWithData:(id)data {
    _editable = [data[@"editable"] boolValue];
    
    _tvAboutMe.hidden = !_editable;
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary hasKeys]) {
        
        self.labelNameAge.text = [NSString stringWithFormat:@"%@, %@", dictionary[@"firstName"], [dictionary[@"age"] stringValue]];
        self.labelGender.text  = [dictionary[@"gender"] capitalizedString];
        self.labelBio.text     = dictionary[@"aboutMe"];
        self.tvAboutMe.text    = dictionary[@"aboutMe"];
        
    }
}

- (void)getAboutMeWithCompletion:(BOOL (^)(NSString *))completion
{
    self.aboutMeChangedBlock = completion;
}


#pragma mark - Text View Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"Text view should begin editing");
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (_aboutMeChangedBlock) {
        NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if (self.aboutMeChangedBlock(string)) {
            self.labelCharacterCount.text = [NSString stringWithFormat:@"%ld", kCLMaxNoteLength - string.length];
            
            return YES;
        }
    }

    return NO;
}

@end
