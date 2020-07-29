//
//  ProfileCell.m
//  YellowHouse
//
//  Created by zurken on 7/29/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "ProfileCell.h"

@implementation ProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAccount:(PFUser *)account {
    _account = account;
    
    self.username.text = account.username;
    self.contactInfo.text = account[@"contactInfo"];
       
    self.profileImage.file = account[@"profileImage"];
    self.profileImage.layer.cornerRadius = 10.0f;
    [self.profileImage loadInBackground];
}

@end
