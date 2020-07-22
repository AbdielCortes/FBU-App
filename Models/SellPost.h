//
//  SellPost.h
//  YellowHouse
//
//  Created by zurken on 7/15/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface SellPost : Post

@property (nonatomic, strong) NSString *contactInfo;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *shippingCost;

+ (void)postSellPost:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withPrice:(NSString * _Nullable)price withShipping:(NSString * _Nullable)shipping  withContactInfo:(NSString * _Nullable)contactInfo withOriginLocation:(NSString * _Nullable)location withCompletion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
