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

@end

@implementation AccountProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchUserData];
}

- (IBAction)tappedFollow:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if ([self.account.objectId isEqual:currentUser.objectId]) { // user is not allowed to follow themself
        return;
    }
    
    NSMutableArray *following = currentUser[@"following"];
    BOOL changed = NO;
    
    if (following) { // user's has already followed some accounts so the array has already been instantiaded
        BOOL foundAccount = NO;
        for (PFUser *accountToFollow in following) { // we search through the followed accounts to see if this account is already being followed by the user
            if ([accountToFollow.objectId isEqual:self.account.objectId]) {
                foundAccount = YES;
            }
        }
        
        if (!foundAccount) { // if the user is not already following this account
            [following addObject:self.account]; // add acount to array
            currentUser[@"following"] = following; // send array to user
            changed = YES;
        }
    }
    else { // this is the first account the user is following so the following array is null
        NSMutableArray *newArray = [[NSMutableArray alloc] init]; // create array
        [newArray addObject:self.account]; // add account
        currentUser[@"following"] = newArray; // send array to user
        changed = YES;
    }
    
    if (changed) { // if the account was added to the following array
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
            if (error) {
                NSLog(@"Error occured while changing user info: %@", error);
            }
        }];
    }
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
