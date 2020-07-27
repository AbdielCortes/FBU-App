//
//  AccountCell.m
//  YellowHouse
//
//  Created by zurken on 7/27/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "AccountCell.h"

@implementation AccountCell

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
    
    self.profileImage.file = account[@"profileImage"];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage loadInBackground];
}

@end
