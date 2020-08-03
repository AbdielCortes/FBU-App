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

@interface PostDetailsViewController : UIViewController

@property (strong, nonatomic) Post *post;

@end

NS_ASSUME_NONNULL_END
