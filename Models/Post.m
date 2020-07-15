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
@dynamic hasLocation;
@dynamic location;
@dynamic likesCount;
@dynamic commentsCount;
@dynamic sharedCount;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void)postUserImage:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withLocation:(NSDictionary *)location withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.author = [PFUser currentUser];
    newPost.image = [Utilities getPFFileFromImage:image];
    newPost.caption = caption;
    newPost.likesCount = @(0);
    newPost.commentsCount = @(0);
    newPost.sharedCount = @(0);
    
    if (location) {
        newPost.location = location;
//        [newPost setHasLocation:YES];
    }
//    else {
//        [newPost setHasLocation:NO];
//    }
    
    [newPost saveInBackgroundWithBlock:completion];
}

@end
