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
@dynamic originLocation;

+ (void)postSellPost:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withPrice:(NSString * _Nullable)price withShipping:(NSString * _Nullable)shipping  withContactInfo:(NSString * _Nullable)contactInfo withOriginLocation:(NSDictionary * _Nullable)location withCompletion:(PFBooleanResultBlock _Nullable)completion {
        
    SellPost *newPost = [SellPost new];
    newPost.author = [PFUser currentUser];
    newPost.image = [Utilities getPFFileFromImage:image];
    newPost.caption = caption;
    newPost.price = price;
    newPost.shippingCost = shipping;
    newPost.contactInfo = contactInfo;
    newPost.likesCount = @(0);
    newPost.commentsCount = @(0);
    newPost.sharedCount = @(0);
    newPost.isSellPost = YES;
    
    if (location) {
        newPost.location = location;
    }
    
    [newPost saveInBackgroundWithBlock:completion];
}

@end
