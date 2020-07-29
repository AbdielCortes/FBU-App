//
//  ProfileCell.h
//  YellowHouse
//
//  Created by zurken on 7/29/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *contactInfo;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followButtonHeight; // button height constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followButtonSpacing; // spacing between button and profile image
@property (strong, nonatomic) NSMutableArray *following;  // array that stores all the accounts that the user is following
@property (nonatomic) BOOL isFollowing; // tells us if the user is already following this accounts

@property (strong, nonatomic) PFUser *account;

- (void)checkIfFollowing; // sets to follow button to its correct function

@end

NS_ASSUME_NONNULL_END
