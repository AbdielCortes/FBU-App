//
//  NoImagePostCell.m
//  YellowHouse
//
//  Created by zurken on 7/17/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "NoImagePostCell.h"
#import "NSDate+DateTools.h"

@implementation NoImagePostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(Post *)post {
    _post = post;
    
    self.profileImage.file = post.author[@"profileImage"];
    [self.profileImage loadInBackground];

    self.username.text = post.author.username;
    self.caption.text = post.caption;
    self.timeSinceCreation.text = post.createdAt.timeAgoSinceNow;
    self.location.text = @"";
}

@end
