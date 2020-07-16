//
//  Utilities.h
//  YellowHouse
//
//  Created by zurken on 7/13/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utilities : NSObject

+ (void)showOkAlert:(UIViewController *)viewController withTitle:(NSString *)title  withMessage:(NSString *)message;

+ (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size;

+ (PFFileObject *)getPFFileFromImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
