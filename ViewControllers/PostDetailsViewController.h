//
//  PostDetailsViewController.h
//  YellowHouse
//
//  Created by zurken on 7/20/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
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

@protocol PostDetailsDelegate

- (void)postDetails:(PostDetailsViewController *)postDetails didTap:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
