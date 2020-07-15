//
//  CreatePostViewController.m
//  YellowHouse
//
//  Created by zurken on 7/14/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "CreatePostViewController.h"
#import "Utilities.h"
#import "Post.h"
#import "SellPost.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <UITextView+Placeholder.h>

@interface CreatePostViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *postLocation;

@property (weak, nonatomic) IBOutlet UISwitch *sellPostSwitch;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UITextField *shippingField;
@property (weak, nonatomic) IBOutlet UITextView *contactInfoTextView;
@property (weak, nonatomic) IBOutlet UIButton *shippingLocation;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Posting";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    // Adding place holder text to text views
    self.captionTextView.placeholder = @"Write caption";
    self.captionTextView.placeholderColor = [UIColor lightGrayColor];
    
    self.contactInfoTextView.placeholder = @"Add contact info";
    self.contactInfoTextView.placeholderColor = [UIColor lightGrayColor];
}

- (IBAction)tappedChooseImage:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)tappedTakePhoto:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
    else { // if camera not available, show error pop up
        [Utilities showOkAlert:self withTitle:@"Camera Not Available" withMessage:@"The camera is not available at the moment, chose an image instead."];
    }
}

- (IBAction)tappedPost:(id)sender {
    [self.hud showAnimated:YES]; // show progress pop up
    
    if (self.sellPostSwitch.isOn) {
        [SellPost postSellPost:self.postImage.image withCaption:self.captionTextView.text withPrice:self.priceField.text withShipping:self.shippingField.text withContactInfo:self.contactInfoTextView.text withOriginLocation:nil withCompletion:^(BOOL succeded, NSError *error) {
            
            if (succeded) {
                self.postImage.image = nil;
                self.captionTextView.text = @"";
                
                self.priceField.text = @"";
                self.shippingField.text = @"";
                self.contactInfoTextView.text = @"";
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                NSLog(@"Error when posting: %@", error);
            }
           
            // hide progress pop up
            // outside if/else because we want it to always hide no matter the result
            [self.hud hideAnimated:YES];
        }];
    }
    else {
        NSDictionary *locat = @{ @"nothing":@(0)};
        [Post postUserImage:self.postImage.image withCaption:self.captionTextView.text withLocation:locat withCompletion:^(BOOL succeded, NSError *error) {

            if (succeded) {
                self.captionTextView.text = @"";
                self.postImage.image = nil;
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                NSLog(@"Error when posting: %@", error);
            }
            
            // hide progress pop up
            // outside if/else because we want it to always hide no matter the result
            [self.hud hideAnimated:YES];
        }];
    }
}

- (IBAction)tappedClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // shrink image resolution to make feel load faster
    UIImage *resizedImage = [self resizeImage:editedImage withSize:CGSizeMake(450, 450)];
    
    self.postImage.image = resizedImage;
    
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
