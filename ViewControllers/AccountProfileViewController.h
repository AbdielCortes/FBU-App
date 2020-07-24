//
//  AccountProfileViewController.h
//  YellowHouse
//
//  Created by zurken on 7/17/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//
//  Shows the profile image, username, and contact info of the account that was selected.
//  Shows a follow/unfollow button, that allows user to follow the account or unfollow them if
//  they were already following the account.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <Parse/Parse.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface AccountProfileViewController : UIViewController

@property (strong, nonatomic) PFUser *account;

@end

NS_ASSUME_NONNULL_END
