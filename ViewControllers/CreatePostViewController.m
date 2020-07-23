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
#import "MapViewController.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <UITextView+Placeholder.h>

@interface CreatePostViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MapViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *postLocation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postLocationHeight;
@property (weak, nonatomic) IBOutlet UILabel *tagLoc;

@property (weak, nonatomic) IBOutlet UISwitch *sellPostSwitch;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
@property (weak, nonatomic) IBOutlet UITextField *shippingField;
@property (weak, nonatomic) IBOutlet UITextView *contactInfoTextView;
@property (weak, nonatomic) IBOutlet UIButton *shippingLocation;
@property (weak, nonatomic) IBOutlet UILabel *whereShip;

@property (strong, nonatomic) NSString *locationName;
@property (nonatomic) BOOL hasLocation;

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
    
    // hide all the sell post fields until the user select that he wants to make a sell post
    self.priceField.hidden = YES;
    self.shippingField.hidden = YES;
    self.contactInfoTextView.hidden = YES;
    self.shippingLocation.hidden = YES;
    self.whereShip.hidden = YES;
    
    // show tag location button
    self.postLocation.hidden = NO;
    self.postLocationHeight.constant = 46;
    self.tagLoc.hidden = NO;
    self.tagLoc.text = @"Tag Location";
    self.locationName = @"";
    self.hasLocation = NO;
    
    // rounding corners
    self.postImage.layer.cornerRadius = 5.0f;
    self.captionTextView.layer.cornerRadius = 5.0f;
    self.contactInfoTextView.layer.cornerRadius = 5.0f;
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

- (IBAction)tappedSellPost:(id)sender {
    if (self.sellPostSwitch.isOn) { // when switch is on show all the sell post fields
        self.priceField.hidden = NO;
        self.shippingField.hidden = NO;
        self.contactInfoTextView.hidden = NO;
        self.shippingLocation.hidden = NO;
        self.whereShip.hidden = NO;
        
        // hide tag location button
        self.postLocation.hidden = YES;
        self.postLocationHeight.constant = 0;
        self.tagLoc.hidden = YES;
        self.tagLoc.text = @"";
    }
    else { // when switch is off hide all the sell post fields
        self.priceField.hidden = YES;
        self.shippingField.hidden = YES;
        self.contactInfoTextView.hidden = YES;
        self.shippingLocation.hidden = YES;
        self.whereShip.hidden = YES;
        
        // show tag location button
        self.postLocation.hidden = NO;
        self.postLocationHeight.constant = 46;
        self.tagLoc.hidden = NO;
        
        if ([self.locationName isEqualToString:@""]) {
            self.tagLoc.text = @"Tag Location";
        }
        else {
            self.tagLoc.text = self.locationName;
        }
    }
}

- (IBAction)tappedPost:(id)sender {
    [self.hud showAnimated:YES]; // show progress pop up
    
    if (self.sellPostSwitch.isOn) { // user selected to create a sell post
        if ([self.priceField.text isEqual:@""]) { // price field has no text
            [Utilities showOkAlert:self withTitle:@"Price Required" withMessage:@"In order to create a sell post you must provide a price."];
            [self.hud hideAnimated:YES];
        }
        else if ([self.shippingField.text isEqual:@""]) { // shipping cost field has no text
            [Utilities showOkAlert:self withTitle:@"Shipping Cost Required" withMessage:@"In order to create a sell post you must provide a shipping cost."];
            [self.hud hideAnimated:YES];
        }
        else if ([self.contactInfoTextView.text isEqual:@""]) { // contact info field has no text
            [Utilities showOkAlert:self withTitle:@"Contact Information Required" withMessage:@"In order to create a sell post you must provide your contact information."];
            [self.hud hideAnimated:YES];
        }
        else if (self.postImage.image == nil) { // user didn't provide image
            [Utilities showOkAlert:self withTitle:@"Image Required" withMessage:@"In order to create a sell post you must provide an image of the product."];
            [self.hud hideAnimated:YES];
        }
        else {
            [SellPost postSellPost:self.postImage.image withCaption:self.captionTextView.text withPrice:self.priceField.text withShipping:self.shippingField.text withContactInfo:self.contactInfoTextView.text withOriginLocation:self.locationName withCompletion:^(BOOL succeded, NSError *error) {
                
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
    }
    else {
        // user didn't provide image or caption
        if (self.postImage.image == nil && [self.captionTextView.text isEqual:@""]) {
            [Utilities showOkAlert:self withTitle:@"Image or Caption Required" withMessage:@"In order to create a post you must provide an image or a caption."];
            [self.hud hideAnimated:YES];
        }
        else {
            [Post postUserImage:self.postImage.image withCaption:self.captionTextView.text withLocation:self.locationName withCompletion:^(BOOL succeded, NSError *error) {

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
}

- (IBAction)tappedClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // shrink image resolution to make feel load faster
    UIImage *resizedImage = [Utilities resizeImage:editedImage withSize:CGSizeMake(450, 450)];
    
    self.postImage.image = resizedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mapViewController:(MapViewController *)controller withLocationName:(NSString *)name {
    if (name) {
        self.tagLoc.text = name;
        self.whereShip.text = name;
        self.locationName = name;
        self.hasLocation = YES;
    }
    else {
        self.tagLoc.text = @"Tag Location";
        self.whereShip.text = @"Where is this item shipping from?";
        self.locationName = @"";
        self.hasLocation = NO;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"TagLocationSegue"] || [segue.identifier  isEqual: @"ShippingLocationSegue"]) {
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.delegate = self;
    }
}

@end
