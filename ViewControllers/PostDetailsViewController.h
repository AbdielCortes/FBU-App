//
//  PostDetailsViewController.h
//  YellowHouse
//
//  Created by zurken on 7/20/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//
//  Shows the post in a full screen view. Tapping on the profile image takes you
//  to that account's profile.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "SellPost.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PostDetailsDelegate;

@interface PostDetailsViewController : UIViewController

@property (strong, nonatomic) Post *post;

@property (nonatomic, weak) id<PostDetailsDelegate> delegate;

@end

// Delegate used when the user taps on the profile image to send the Account to the AccountProfile view
@protocol PostDetailsDelegate

- (void)postDetails:(PostDetailsViewController *)postDetails didTap:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
