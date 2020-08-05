//
//  CommentCell.m
//  YellowHouse
//
//  Created by zurken on 7/31/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "CommentCell.h"
#import "NSDate+DateTools.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setComment:(Comment *)comment {
    self.commentText.text = comment.text;
    
    self.timeSinceCreation.text = comment.createdAt.shortTimeAgoSinceNow;
    
    self.username.text = comment.author.username;

    self.profileImage.file = comment.author[@"profileImage"];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage loadInBackground];
}

@end
