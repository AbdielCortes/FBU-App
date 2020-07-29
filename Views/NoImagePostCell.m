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
    
    self.profileImage.file = post.author[@"profileImage"];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage loadInBackground];

    self.username.text = post.author.username;
    self.caption.text = post.caption;
    self.timeSinceCreation.text = post.createdAt.timeAgoSinceNow;
    self.location.text = self.post.locationName;;
    
    self.likeCount.text = [NSString stringWithFormat:@"%lu", post.userLike.count];
    [self checkIfLiked];
}

- (void)checkIfLiked {
    self.liked = NO;
    for (PFUser *user in self.post.userLike) {
        // if current user is inside this post's userLike array
        if ([user.objectId isEqual:[PFUser currentUser].objectId]) {
            self.liked = YES;
        }
    }
    
    // set like button to correct state depending on if its liked or not
    if (self.liked) {
        self.likeButton.selected = YES;
    }
    else {
        self.likeButton.selected = NO;
    }
}

- (IBAction)tappedLike:(id)sender {
    if (self.liked) { // unliking
        // set button to look default
        self.likeButton.selected = NO;
        
        // remove current user from userLike array
        NSMutableArray *withoutCurrentUser = [[NSMutableArray alloc] init]; // create new array to store all accounts except this one
        for (PFUser *currentAccount in self.post.userLike) { // we search through the followed accounts to find this account
            // if account is not equal to the currentUser
            if (![currentAccount.objectId isEqual:[PFUser currentUser].objectId]) {
                [withoutCurrentUser addObject:currentAccount]; // add account ot new array
            }
        }
        self.post.userLike = withoutCurrentUser;
        self.post[@"userLike"] = withoutCurrentUser;
        
        // update like count label
        self.likeCount.text = [NSString stringWithFormat:@"%lu", self.post.userLike.count];
        // update liked boolean value
        self.liked = NO;
    }
    else { // liking
        // set button to look selected
        self.likeButton.selected = YES;
        // add current user to userLike array
        [self.post.userLike addObject:[PFUser currentUser]];
        self.post[@"userLike"] = self.post.userLike;
        // update like count label
        self.likeCount.text = [NSString stringWithFormat:@"%lu", self.post.userLike.count];
        // update liked boolean value
        self.liked = YES;
    }
    
    // save the changes to parse
    [self.post saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (error) {
            NSLog(@"Error occured while changing user info: %@", error);
        }
    }];
}

// send post to AccountProfile when the profile image was tapped
- (void)tappedProfileImage:(UITapGestureRecognizer *)sender {
    [self.delegate noImagePostCell:self didTap:self.post.author];
}

@end
