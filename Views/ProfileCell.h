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

@property (strong, nonatomic) PFUser *account;

@end

NS_ASSUME_NONNULL_END
