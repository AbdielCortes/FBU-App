//
//  SellPost.m
//  YellowHouse
//
//  Created by zurken on 7/15/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "SellPost.h"
#import "Utilities.h"

@implementation SellPost

@dynamic contactInfo;
@dynamic price;
@dynamic shippingCost;

+ (void)postSellPost:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withPrice:(NSString * _Nullable)price withShipping:(NSString * _Nullable)shipping  withContactInfo:(NSString * _Nullable)contactInfo withOriginLocation:(NSString * _Nullable)location withCompletion:(PFBooleanResultBlock _Nullable)completion {
        
    SellPost *newPost = [SellPost new];
    newPost.author = [PFUser currentUser];
    newPost.image = [Utilities getPFFileFromImage:image]; // convert image into a file so that we can store it in Parse
    newPost.hasImage = YES;
    newPost.caption = caption;
    newPost.price = price;
    newPost.shippingCost = shipping;
    newPost.contactInfo = contactInfo;
    newPost.likesCount = @(0);
    newPost.commentsCount = @(0);
    newPost.sharedCount = @(0);
    newPost.isSellPost = YES;
    
    if (location) {
        newPost.locationName = location;
    }
    else {
        newPost.locationName = @"";
    }
    
    // send sell post to Parse
    [newPost saveInBackgroundWithBlock:completion];
}

@end
