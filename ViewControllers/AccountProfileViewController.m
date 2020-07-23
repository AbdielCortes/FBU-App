//
//  AccountProfileViewController.m
//  YellowHouse
//
//  Created by zurken on 7/17/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "AccountProfileViewController.h"
#import <Parse/Parse.h>

@interface AccountProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *contactInfo;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) NSMutableArray *following;
@property (nonatomic) BOOL isFollowing;

@end

@implementation AccountProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchUserData];
    
    self.followButton.hidden = NO;
    if ([self.account.objectId isEqual:[PFUser currentUser].objectId]) { // user is not allowed to follow themself
        self.followButton.hidden = YES; // hide follow button so that the user can't click it
    }
    else {
        self.following = [PFUser currentUser][@"following"];
        self.isFollowing = NO;
        if (self.following) { // if following array is not null
            for (PFUser *accountToFollow in self.following) { // we search through the followed accounts to see if this account is already being followed by the user
                if ([accountToFollow.objectId isEqual:self.account.objectId]) { // user is following this account
                    self.isFollowing = YES;
                    [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
                }
            }
        }
    }
}

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

- (void)fetchUserData {
    self.username.text = self.account.username;
    self.contactInfo.text = self.account[@"contactInfo"];
    
    self.profileImage.file = self.account[@"profileImage"];
    self.profileImage.layer.cornerRadius = 10.0f;
    [self.profileImage loadInBackground];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
