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

@interface PostCell () <UIScrollViewDelegate>

@end

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Gesture recognizer for tapping on profile image
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedProfileImage:)];
    [self.profileImage addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
    
    // set up scroll view for image zooming
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = CGSizeMake(450, 450);
    self.scrollView.delegate = self;
    self.scrollView.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(Post *)post {
    _post = post;
    
    self.username.text = post.author.username;
    self.caption.text = post.caption;
    // converts date into a string that says how long ago the post was created
    // example: "2 hours ago"
    self.timeSinceCreation.text = post.createdAt.timeAgoSinceNow;
    // use formatter to show the date when the post was created
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.createdAt.text = [formatter stringFromDate:self.post.createdAt];
    
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
    
    if (post.isSellPost) { // if post is a sell post 
        SellPost *sellPost = (SellPost *)post; // cast Post into SellPost
        
        NSString *price;
        NSString *shipping;
        if ([@([sellPost.price doubleValue]) isEqualToNumber:@(0)]) { // if the user typed 0 for the price
            price = @"Free";
        }
        else {
            price = [NSString stringWithFormat:@"$%@", sellPost.price];
        }
        if ([@([sellPost.shippingCost doubleValue]) isEqualToNumber:@(0)]) { // if the user typed 0 for the shipping
            shipping = @"free shipping";
        }
        else {
            shipping = [NSString stringWithFormat:@"$%@ shipping", sellPost.shippingCost];
        }
        self.priceAndShipping.text = [NSString stringWithFormat:@"%@ + %@", price, shipping];

        self.contactInfo.text = sellPost.contactInfo;
        
        if ([self.post.locationName isEqualToString:@""]) {
            self.location.text = @"";
        }
        else {
            self.location.text = [NSString stringWithFormat:@"Ships from %@", self.post.locationName];
        }
    }
    else { // post is a regular post
        self.priceAndShipping.text = @"";
        self.contactInfo.text = @"";
        self.location.text = self.post.locationName;
    }
    
    // set like count label
    [self updateLikeCount];
    
    // set like button state
    [self checkIfLiked];
    
    // set comment count label
    if (post.comments.count > 0 && post.comments.count < 1000) {
        self.commentCount.text = [NSString stringWithFormat:@"%lu", post.comments.count];
    }
    else if (post.comments.count >= 1000) {
        self.commentCount.text = @"999+";
    }
    else {
        self.commentCount.text = @"";
    }
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

- (void)updateLikeCount {
    if (self.post.userLike.count > 0 && self.post.userLike.count < 1000) {
        self.likeCount.text = [NSString stringWithFormat:@"%lu", self.post.userLike.count];
    }
    else if (self.post.userLike.count >= 1000) {
        self.likeCount.text = @"999+";
    }
    else {
        self.likeCount.text = @"";
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.postImage;
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
        [self updateLikeCount];
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
        [self updateLikeCount];
        // update liked boolean value
        self.liked = YES;
    }
    
    // save the changes to parse
    [self.post saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (error) {
            NSLog(@"Error occured while saving like: %@", error);
        }
    }];
}

- (IBAction)tappedShare:(id)sender {
    // create array to store the objects that will be shared
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    // add post image to array
    [activityItems addObject:self.postImage.image];
    // create string to store all the strings contained in a post
    NSString *postString = @"";
    if (![self.caption.text isEqualToString:@""]) { // if the post has a caption
        postString = [NSString stringWithFormat:@"%@ posted: %@", self.post.author.username, self.caption.text];
    }

    if (self.post.isSellPost) { // if the post is a sell post
        if ([self.caption.text isEqualToString:@""]) { // if the post dosen't have a caption
            postString = [NSString stringWithFormat:@"%@\n%@", self.priceAndShipping.text, self.contactInfo.text];
        }
        else {
            postString = [NSString stringWithFormat:@"%@\n%@\n%@", postString, self.priceAndShipping.text, self.contactInfo.text];
        }
    }

    if (![self.location.text isEqualToString:@""]) { // if the post has a location
        postString = [NSString stringWithFormat:@"%@\n%@", postString, self.location.text];
    }
    
    // if the post where to have all the fields, then the final string will look like this
    // username posted: postCaption
    // $99 + $99 shipping
    // contactInfo
    // location
    if (![postString isEqualToString:@""]) {
        [activityItems addObject:postString];
    }

    // call delegate method to show activity view controller
    [self.delegate postCell:self share:activityItems];
}

// send post to AccountProfile when the profile image was tapped
- (void)tappedProfileImage:(UITapGestureRecognizer *)sender {
    [self.delegate postCell:self didTap:self.post.author];
}

@end
