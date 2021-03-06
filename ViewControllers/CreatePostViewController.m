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

@interface CreatePostViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, MapViewControllerDelegate>

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

@property (nonatomic) int captionTextLimit;
@property (nonatomic) int contactInfoTextLimit;
@property (nonatomic) BOOL isOverTextLimit;

@property (strong, nonatomic) NSString *locationName;
@property (nonatomic) BOOL hasLocation; // tells us if the user has tagged a location

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
    self.priceField.alpha = 0;
    self.shippingField.alpha = 0;
    self.contactInfoTextView.alpha = 0;
    self.shippingLocation.alpha = 0;
    self.whereShip.alpha = 0;
    
    // show tag location button
    self.postLocation.alpha = 1;
    self.postLocationHeight.constant = 35;
    self.tagLoc.alpha = 1;
    self.tagLoc.text = @"Tag Location";
    
    // has no location by default
    self.locationName = @"";
    self.hasLocation = NO;
    
    // rounding corners
    self.postImage.layer.cornerRadius = 5.0f;
    self.captionTextView.layer.cornerRadius = 5.0f;
    self.contactInfoTextView.layer.cornerRadius = 5.0f;
    
    // set background colors and delegates for text view character limits
    self.captionTextView.delegate = self;
    self.captionTextView.backgroundColor = [UIColor systemGray6Color];
    self.captionTextLimit = 250;
    self.contactInfoTextView.delegate = self;
    self.contactInfoTextView.backgroundColor = [UIColor systemGray6Color];
    self.contactInfoTextLimit = 80;
    self.isOverTextLimit = NO;
    
    // sell post switch on color
    self.sellPostSwitch.onTintColor = [UIColor colorWithRed:1 green:0.87 blue:0.235 alpha:1];
    
    // text field delegates for moving the view up when the keyboard is covering it
    self.priceField.delegate = self;
    self.shippingField.delegate = self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.captionTextView) { // editing caption
        // get text that's currently in text view
        NSString *currentText = [self.captionTextView.text stringByReplacingCharactersInRange:range withString:text];
        if (currentText.length > self.captionTextLimit) { // text is longer than the character limit
            self.captionTextView.backgroundColor = [UIColor colorWithRed:1 green:0.47 blue:0.47 alpha:0.8];
            self.isOverTextLimit = YES;
        }
        else {
            self.captionTextView.backgroundColor = [UIColor systemGray6Color];
            self.isOverTextLimit = NO;
        }
    }
    else if (textView == self.contactInfoTextView) { // edition contact info
        // get text that's currently in text view
        NSString *currentText = [self.contactInfoTextView.text stringByReplacingCharactersInRange:range withString:text];
        if (currentText.length > self.contactInfoTextLimit) {
            self.contactInfoTextView.backgroundColor = [UIColor colorWithRed:1 green:0.47 blue:0.47 alpha:0.8];
            self.isOverTextLimit = YES;
        }
        else {
            self.contactInfoTextView.backgroundColor = [UIColor systemGray6Color];
            self.isOverTextLimit = NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // calculate textField y distance from the center of the screen
    // if positive, its above the center
    // if negative, its below the center
    CGFloat y = (self.view.frame.size.height / 2) - textField.frame.origin.y;
    if (y < 0) { // we only want to move the view up, so we only move it when its negative
        [self.view setFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height)];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    // move view back to its original position
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    [self.view endEditing:YES];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    // calculate textField y distance from the center of the screen
    // if positive, its above the center
    // if negative, its below the center
    CGFloat y = (self.view.frame.size.height / 2) - textView.frame.origin.y;
    if (y < 0) { // we only want to move the view up, so we only move it when its negative
        [self.view setFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height)];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    // move view back to its original position
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    [self.view endEditing:YES];
}

// hides the keyboard when the user taps outside keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// opens the image gallery to pick an image and then set it as the post's image
- (IBAction)tappedChooseImage:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// opens camera to take a picture and then set it as the post's image
- (IBAction)tappedTakePhoto:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
    else { // if camera is not available, show error pop up
        [Utilities showOkAlert:self withTitle:@"Camera Not Available" withMessage:@"The camera is not available at the moment, chose an image instead."];
    }
}

- (IBAction)tappedSellPost:(id)sender {
    if (self.sellPostSwitch.isOn) { // when switch is on show all the sell post fields
        [UIView animateWithDuration:0.8 animations:^{
            self.priceField.alpha = 1;
            self.shippingField.alpha = 1;
            self.contactInfoTextView.alpha = 1;
            self.shippingLocation.alpha = 1;
            self.whereShip.alpha = 1;
            
            self.postLocation.alpha = 0;
            self.postLocationHeight.constant = 0;
            self.tagLoc.alpha = 0;
            
            [self.view layoutIfNeeded];
        }];
        self.tagLoc.text = @"";
    }
    else { // when switch is off hide all the sell post fields
        [UIView animateWithDuration:0.8 animations:^{
            self.priceField.alpha = 0;
            self.shippingField.alpha = 0;
            self.contactInfoTextView.alpha = 0;
            self.shippingLocation.alpha = 0;
            self.whereShip.alpha = 0;
            
            self.postLocation.alpha = 1;
            self.postLocationHeight.constant = 35;
            self.tagLoc.alpha = 1;
            
            [self.view layoutIfNeeded];
        }];
        if ([self.locationName isEqualToString:@""]) { // user didn't select a location
            self.tagLoc.text = @"Tag Location";
        }
        else { // user selected a location
            self.tagLoc.text = self.locationName;
        }
    }
}

- (IBAction)tappedPost:(id)sender {
    [self.hud showAnimated:YES]; // show progress pop up
    
    if (self.sellPostSwitch.isOn) { // user selected to create a sell post
        if (self.isOverTextLimit) { // text is exceeding the character limit
            [Utilities showOkAlert:self withTitle:@"Over Text Limit" withMessage:@"Your caption or contact info is exceeding the character limit."];
            [self.hud hideAnimated:YES];
        }
        else if ([self.priceField.text isEqual:@""]) { // price field has no text
            [Utilities showOkAlert:self withTitle:@"Price Required" withMessage:@"In order to create a sell post you must provide a price."];
            [self.hud hideAnimated:YES];
        }
        else if (![self validateMoney:self.priceField.text]) { // price does not follow curency format
            [Utilities showOkAlert:self withTitle:@"Invalid Price" withMessage:@"Price does not conform to the curency format."];
            [self.hud hideAnimated:YES];
        }
        else if ([self.shippingField.text isEqual:@""]) { // shipping cost field has no text
            [Utilities showOkAlert:self withTitle:@"Shipping Cost Required" withMessage:@"In order to create a sell post you must provide a shipping cost."];
            [self.hud hideAnimated:YES];
        }
        else if (![self validateMoney:self.shippingField.text]) { // shipping does not follow curency format
            [Utilities showOkAlert:self withTitle:@"Invalid Shipping" withMessage:@"Shipping does not conform to the curency format."];
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
            // send post to Parse
            [SellPost postSellPost:self.postImage.image withCaption:self.captionTextView.text withPrice:self.priceField.text withShipping:self.shippingField.text withContactInfo:self.contactInfoTextView.text withOriginLocation:self.locationName withCompletion:^(BOOL succeded, NSError *error) {
                
                if (succeded) {
                    // empty text fields and segue back to home feed
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
        if (self.isOverTextLimit) { // text is exceeding the character limit
            [Utilities showOkAlert:self withTitle:@"Over Text Limit" withMessage:@"Your caption or contact info is exceeding the character limit."];
            [self.hud hideAnimated:YES];
        }
        else if (self.postImage.image == nil && [self.captionTextView.text isEqual:@""]) { // user didn't provide image or caption
            [Utilities showOkAlert:self withTitle:@"Image or Caption Required" withMessage:@"In order to create a post you must provide an image or a caption."];
            [self.hud hideAnimated:YES];
        }
        else {
            // send post to Parse
            [Post postUserImage:self.postImage.image withCaption:self.captionTextView.text withLocation:self.locationName withCompletion:^(BOOL succeded, NSError *error) {

                if (succeded) {
                    // empty text fields and segue back to home feed
                    self.postImage.image = nil;
                    self.captionTextView.text = @"";
                    
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

// validate any money inputs
// accepts: 50, 100, 1.11, 2000000.55
// dosen't accept: 0500, 30., 5.1, 4.111
- (BOOL)validateMoney:(NSString *)money {
    NSString *moneyRegex = @"^([1-9][0-9]*|[0]{1})([0-9]{0}|[.]{0,1}[0-9]{2})$";
    NSPredicate *moneyTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", moneyRegex];
    return [moneyTest evaluateWithObject:money];
}

- (IBAction)tappedClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // shrink image resolution to make feel load faster
    UIImage *resizedImage = [Utilities resizeImage:editedImage withSize:CGSizeMake(450, 450)];
    // shows selected image
    self.postImage.image = resizedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mapViewController:(MapViewController *)controller withLocationName:(NSString *)name {
    if (name) { // if name is not null then the user tagged a location
        self.tagLoc.text = name;
        self.whereShip.text = name;
        self.locationName = name;
        self.hasLocation = YES;
    }
    else { // the user opended the map view controller but didn't tag a location
        self.tagLoc.text = @"Tag Location";
        self.whereShip.text = @"Where is this item shipping from?";
        self.locationName = @"";
        self.hasLocation = NO;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue to map view, assing delegate so that we can retrieve the info from the map view
    if ([segue.identifier  isEqual: @"TagLocationSegue"] || [segue.identifier  isEqual: @"ShippingLocationSegue"]) {
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.delegate = self;
    }
}

@end
