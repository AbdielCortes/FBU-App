//
//  PostCell.h
//  YellowHouse
//
//  Created by zurken on 7/14/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//
//  PostCell is a UITableViewCell used in the HomeFeedViewController to display posts with
//  images and sell posts. The PostCell has a Post as one of its properties and all the labels
//  are assigned using this property with the method setPost.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <Parse/Parse.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol PostCellDelegate;

@interface PostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *createdAt;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceCreation;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *priceAndShipping;
@property (weak, nonatomic) IBOutlet UILabel *contactInfo;

@property (weak, nonatomic) IBOutlet UILabel *commentCount;

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (nonatomic) BOOL liked; // tells us if the user has already liked this post

@property (weak, nonatomic) IBOutlet UILabel *shareCount;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet PFImageView *postImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) Post *post;

@property (nonatomic, weak) id<PostCellDelegate> delegate;

@end

@protocol PostCellDelegate

// used when the user taps on the profile image to send the Account to the AccountProfile view
- (void)postCell:(PostCell *)postCell didTap:(PFUser *)user;
// used when the user taps share to show the share action sheet
- (void)postCell:(PostCell *)postCell share:(NSArray *)activityItems;

@end

NS_ASSUME_NONNULL_END
