//
//  Post.h
//  YellowHouse
//
//  Created by zurken on 7/14/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject <PFSubclassing>

@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSNumber *likesCount;
@property (nonatomic, strong) NSNumber *commentsCount;
@property (nonatomic, strong) NSNumber *sharedCount;
@property (nonatomic) BOOL hasImage;
@property (nonatomic) BOOL isSellPost;

+ (void)postUserImage:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withLocation:(NSString * _Nullable)location withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
