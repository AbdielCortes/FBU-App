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

// checks if the user is already following this account
// this method must be called when the cell is created right after "setAccount" is called
// when the user is following the account it changes the button to "Following"
// when the user is NOT following the account the button shows as "Follow"
// when the user is looking at his own account the button is hidden
- (void)checkIfFollowing {
    self.followButton.hidden = NO;
    if ([self.account.objectId isEqual:[PFUser currentUser].objectId]) { // user is not allowed to follow themself
        self.followButton.hidden = YES; // hide follow button so that the user can't click it
        // modify constraints so that the spacing without the button looks right 
        self.followButtonHeight.constant = 0;
        self.followButtonSpacing.constant = 0;
    }
    else { // user is not looking at their own profile
        self.following = [PFUser currentUser][@"following"]; // get array of accounts that the user is following
        self.isFollowing = NO;
        if (self.following) { // if following array is not null
            // we search through the followed accounts to see if this account is already being followed by the user
            for (PFUser *accountToFollow in self.following) {
                if ([accountToFollow.objectId isEqual:self.account.objectId]) { // user is following this account
                    self.isFollowing = YES;
                    [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
                }
            }
        }
    }
}

// follows the account if the user is not already following it, or unfollows the account
// if the user is already following it
//
// if the user is not following the account, then:
//    if  the following array is not null, then add the account
//    else create an array and add the account
//
// else the user is already following this account:
//    for loop to remove this account from the array
//
// save following array in database
- (IBAction)tappedFollow:(id)sender {
    PFUser *currentUser = [PFUser currentUser];

    if (!self.isFollowing) { // if user is not following this account
        if (self.following) { // if following arra is not null (array is null when this is the first account the user follows)
            [self.following addObject:self.account]; // add acount to array
            currentUser[@"following"] = self.following; // send array to user
        }
        else { // this is the first account the user is following so the following array is null
            NSMutableArray *newArray = [[NSMutableArray alloc] init]; // create array
            [newArray addObject:self.account]; // add account
            currentUser[@"following"] = newArray; // send array to user
        }

        self.isFollowing = YES;
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal]; // change button text
    }
    else {
        NSMutableArray *withoutAccount = [[NSMutableArray alloc] init]; // create new array to store all accounts except this one
        for (PFUser *currentAccount in self.following) { // we search through the followed accounts to find this account
            // if account is not equal to the account that we want to remove
            if (![currentAccount.objectId isEqual:self.account.objectId]) {
                [withoutAccount addObject:currentAccount]; // add account ot new array
            }
        }

        self.following = withoutAccount; // update following array
        currentUser[@"following"] = withoutAccount; // send new array to user
        self.isFollowing = NO;
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal]; // change button text
    }

    // save the changes to parse
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (error) {
            NSLog(@"Error occured while changing user info: %@", error);
        }
    }];
}

@end
