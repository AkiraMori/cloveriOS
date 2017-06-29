//
//  CLReportCommentsCell.m
//  Partake
//
//  Created by Maikel on 08/09/15.
//  Copyright (c) 2015 SCF Ventures LLC. All rights reserved.
//

#import "CLReportCommentsCell.h"
#import "CLTextView.h"


@interface CLReportCommentsCell () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet CLTextView *textView;

@property (copy, nonatomic) void(^textChangedBlock)(NSString *);

@end


@implementation CLReportCommentsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.textView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)getCommentTextWithCompletion:(void(^)(NSString *))completion {
    self.textChangedBlock = completion;
}

- (void)configureCellWithDictionary:(NSDictionary *)dictionary
{
    
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.textChangedBlock) {
        self.textChangedBlock(textView.text);
    }
}
@end
