//
//  PostCell.m
//  YellowHouse
//
//  Created by zurken on 7/14/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "PostCell.h"
#import "SellPost.h"
#import "NSDate+DateTools.h"

@implementation PostCell

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
    
    self.username.text = post.author.username;
    self.caption.text = post.caption;
    
    self.timeSinceCreation.text = post.createdAt.timeAgoSinceNow;
    
    self.postImage.file = post[@"image"];
    
    [self.postImage loadInBackground];
    
    self.location.text = @"";
    
    if (post.isSellPost) { // if post is a sell post 
        SellPost *sellPost = (SellPost *)post;
        self.priceAndShipping.text = [NSString stringWithFormat:@"$%@ + $%@ shipping", sellPost.price, sellPost.shippingCost];
        self.contactInfo.text = sellPost.contactInfo;
    }
    else {
        self.priceAndShipping.text = @"";
        self.contactInfo.text = @"";
    }
    
//    if (self.postImage.file == nil) {
//        self.postImage.hidden = YES;
//        self.imageRatioConstraint.active = NO;
//    }
//    else {
//        self.postImage.hidden = NO;
//        self.imageRatioConstraint.active = YES;
//        [self.postImage loadInBackground];
//    }
}

@end
