//
//  Utilities.m
//  YellowHouse
//
//  Created by zurken on 7/13/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

// Shows a pop up alert with only an ok option
+ (void)showOkAlert:(UIViewController *)viewController withTitle:(NSString *)title  withMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];

    [viewController presentViewController:alert animated:YES completion:^{}];
}

// Takes UImage and returns a PFFile
// used for sending images to Parse
+ (PFFileObject *)getPFFileFromImage:(UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

@end
