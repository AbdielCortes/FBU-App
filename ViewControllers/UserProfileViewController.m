//
//  UserProfileViewController.m
//  YellowHouse
//
//  Created by zurken on 7/16/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "UserProfileViewController.h"
#import <Parse/Parse.h>
@import Parse;

@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *contactInfo;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchUserData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // call fetch user here so that when the user changes his info and comes back
    // the viewl will reload the user data
    [self fetchUserData];
}

- (void)fetchUserData {
    PFUser *user = [PFUser currentUser];
    
    self.username.text = user.username;
    self.contactInfo.text = user[@"contactInfo"];
    
    self.profileImage.file = user[@"profileImage"];
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
