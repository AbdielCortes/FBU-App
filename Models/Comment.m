//
//  Comment.m
//  YellowHouse
//
//  Created by zurken on 7/31/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@dynamic author;
@dynamic parentPost;
@dynamic text;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (Comment *)postComment:(NSString *)text withParentPost:(NSString *)postId withCompletion:(PFBooleanResultBlock _Nullable)completion {
    Comment *newComment = [Comment new];

    newComment.author = [PFUser currentUser];
    newComment.parentPost = postId;
    newComment.text = text;

    // send comment to Parse
    [newComment saveInBackgroundWithBlock:completion];

    return newComment;
}

@end
