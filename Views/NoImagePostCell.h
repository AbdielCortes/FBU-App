//
//  NoImagePostCell.h
//  YellowHouse
//
//  Created by zurken on 7/17/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//
//  PostCell is a UITableViewCell used in the HomeFeedViewController to display posts with no
//  images. The NoImage PostCell has a Post as one of its properties and all the labels
//  are assigned using this property with the method setPost.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <Parse/Parse.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol NoImagePostCellDelegate;

@interface NoImagePostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *createdAt;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceCreation;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *location;

@property (weak, nonatomic) IBOutlet UILabel *commentCount;

@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (nonatomic) BOOL liked; // tells us if the user has already liked this post

@property (weak, nonatomic) IBOutlet UILabel *shareCount;

@property (strong, nonatomic) Post *post;

@property (nonatomic, weak) id<NoImagePostCellDelegate> delegate;

@end

@protocol NoImagePostCellDelegate
// used when the user taps on the profile image to send the Account to the AccountProfile view
- (void)noImagePostCell:(NoImagePostCell *)noImagePostCell didTap:(PFUser *)user;
// used when the user taps share to show the share action sheet
- (void)noImagePostCell:(NoImagePostCell *)noImagePostCell share:(NSArray *)activityItems;

@end

NS_ASSUME_NONNULL_END
