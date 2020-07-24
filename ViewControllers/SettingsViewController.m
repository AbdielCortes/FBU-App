//
//  SettingsViewController.m
//  YellowHouse
//
//  Created by zurken on 7/16/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "SettingsViewController.h"
#import "Utilities.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <UITextView+Placeholder.h>
#import <Parse/Parse.h>
@import Parse;

@interface SettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *contactInfoTextView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Saving Changes";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    // Adding place holder text to contact info text view
    self.contactInfoTextView.placeholder = @"Contact info";
    self.contactInfoTextView.placeholderColor = [UIColor lightGrayColor];
    
    // rounding corners
    self.profileImage.layer.cornerRadius = 10.0f;
    self.contactInfoTextView.layer.cornerRadius = 5.0f;
}

// open image gallery so that the user can pick a profile picture
- (IBAction)tappedProfileImage:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// sends updates user data to Parse
- (IBAction)tappedConfirm:(id)sender {
    BOOL changed = NO; // keeps track of wether the user made a change or not
    
    if (![self.contactInfoTextView.text isEqual:@""]) { // user changed contact info
       [PFUser currentUser][@"contactInfo"] = self.contactInfoTextView.text;
        changed = YES;
    }
    
    if (self.profileImage.image != nil) { // user changed image
        [PFUser currentUser][@"profileImage"] = [Utilities getPFFileFromImage:self.profileImage.image];
        changed = YES;
    }
    
    if (changed) { // user changed contact info or profile image
        [self.hud showAnimated:YES]; // show progress pop up
        // save changes
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
            if (succeded) {
                self.profileImage.image = nil;
                self.contactInfoTextView.text = @"";
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                NSLog(@"Error occured while changing user info: %@", error);
            }
            
           // hide progress pop up
           // outside if/else because we want it to always hide no matter the result
           [self.hud hideAnimated:YES];
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // shrink image resolution to make feel load faster
    UIImage *resizedImage = [Utilities resizeImage:editedImage withSize:CGSizeMake(450, 450)];
    // shows selected image
    self.profileImage.image = resizedImage;
    
    // dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
