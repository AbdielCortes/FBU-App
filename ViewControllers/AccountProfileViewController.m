//
//  AccountProfileViewController.m
//  YellowHouse
//
//  Created by zurken on 7/17/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "AccountProfileViewController.h"

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
    
}

- (void)fetchUserData {
    self.username.text = self.account.username;
    self.contactInfo.text = self.account[@"contactInfo"];
    
    self.profileImage.file = self.account[@"profileImage"];
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
