//
//  LoginViewController.m
//  YellowHouse
//
//  Created by zurken on 7/13/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "LoginViewController.h"
#import "Utilities.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Logging In";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    self.loginButton.layer.cornerRadius = 5.0f;
    self.signUpButton.layer.cornerRadius = 5.0f;
}

- (IBAction)tappedLogin:(id)sender {
    [self.hud showAnimated:YES]; // show progress pop up
    
    if ([self.usernameField.text isEqual:@""]) { // username field has no text
        [Utilities showOkAlert:self withTitle:@"Username Required" withMessage:@"In order to login you must provide a username."];
        [self.hud hideAnimated:YES];
    }
    else if ([self.passwordField.text isEqual:@""]) { // password field has no text
        [Utilities showOkAlert:self withTitle:@"Password Required" withMessage:@"In order to login you must provide a password."];
        [self.hud hideAnimated:YES];
    }
    else {
        [self loginUser];
    }
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    // sends loggin info to Parse
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            
            if (error.code == 101) {// incorrect username/password
                [Utilities showOkAlert:self withTitle:@"Invalid Login" withMessage:@"Username and password combination is invalid."];
            }
        }
        else {
            [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
        }
        
        // hide progress pop up
        // outside if/else because we want it to always hide no matter the result
        [self.hud hideAnimated:YES];
    }];
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
