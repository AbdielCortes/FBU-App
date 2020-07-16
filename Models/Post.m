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
@dynamic location;
@dynamic likesCount;
@dynamic commentsCount;
@dynamic sharedCount;
@dynamic isSellPost;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void)postUserImage:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withLocation:(NSDictionary * _Nullable)location withCompletion:(PFBooleanResultBlock _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.author = [PFUser currentUser];
    newPost.image = [Utilities getPFFileFromImage:image];
    newPost.caption = caption;
    newPost.likesCount = @(0);
    newPost.commentsCount = @(0);
    newPost.sharedCount = @(0);
    newPost.isSellPost = NO;
    
    if (location) {
        newPost.location = location;
    }
    
    [newPost saveInBackgroundWithBlock:completion];
}

@end
