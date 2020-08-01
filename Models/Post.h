//
//  Post.h
//  YellowHouse
//
//  Created by zurken on 7/14/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//
//  Post is a PFObject used to store all the data in a post using Parse. A post object is first
//  created locally and then sent to the parse database. An image is stored as a file and in order to
//  convert it into an image we use ParseUI.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject <PFSubclassing>

@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSMutableArray *userLike;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic) BOOL hasImage;
@property (nonatomic) BOOL isSellPost;

// creates post object and sends it to parses
+ (void)postUserImage:(UIImage * _Nullable)image withCaption:(NSString * _Nullable)caption withLocation:(NSString * _Nullable)location withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
