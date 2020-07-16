//
//  SettingsViewController.m
//  YellowHouse
//
//  Created by zurken on 7/16/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "SettingsViewController.h"
#import "Utilities.h"
#import <Parse/Parse.h>
@import Parse;

@interface SettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *contactInfoTextView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)tappedProfileImage:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)tappedConfirm:(id)sender {
    
    [PFUser currentUser][@"contactInfo"] = self.contactInfoTextView.text;
    
    [PFUser currentUser][@"profileImage"] = [Utilities getPFFileFromImage:self.profileImage.image];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (succeded) {
            NSLog(@"saved user");
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // shrink image resolution to make feel load faster
    UIImage *resizedImage = [Utilities resizeImage:editedImage withSize:CGSizeMake(450, 450)];
    
    self.profileImage.image = resizedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
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
