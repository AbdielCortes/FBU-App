//
//  Post.m
//  YellowHouse
//
//  Created by zurken on 7/14/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "Post.h"
#import "Utilities.h"

@implementation Post

@dynamic author;
@dynamic image;
@dynamic caption;
@dynamic locationName;
@dynamic userLike;
@dynamic hasImage;
@dynamic isSellPost;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void)postUserImage:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withLocation:(NSString * _Nullable)location withCompletion:(PFBooleanResultBlock _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.author = [PFUser currentUser];
    
    if (image) {
        newPost.hasImage = YES;
        // convert image into a file so that we can store it in Parse
        newPost.image = [Utilities getPFFileFromImage:image];
    }
    else {
        newPost.hasImage = NO;
    }
    
    newPost.caption = caption;
    newPost.userLike = [[NSMutableArray alloc] init];
    newPost.isSellPost = NO;
    
    if (location) {
        newPost.locationName = location;
    }
    else {
        newPost.locationName = @"";
    }
    
    // send post to Parse
    [newPost saveInBackgroundWithBlock:completion];
}

@end
