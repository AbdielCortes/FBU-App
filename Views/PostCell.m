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
    
    // Gesture recognizer for tapping on profile image
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedProfileImage:)];
    [self.profileImage addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
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
    
    self.profileImage.file = post.author[@"profileImage"];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage loadInBackground];
    
    self.postImage.layer.cornerRadius = 5.0f;
    // gets image from parse
    [post[@"image"] getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            self.postImage.image = image;
        }
        else {
            NSLog(@"error loading image: %@", error);
        }
    }];
    
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
}

- (void)tappedProfileImage:(UITapGestureRecognizer *)sender {
    [self.delegate postCell:self didTap:self.post.author];
}

@end
