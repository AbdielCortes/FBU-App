//
//  NoImagePostCell.h
//  YellowHouse
//
//  Created by zurken on 7/17/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <Parse/Parse.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol NoImagePostCellDelegate;

@interface NoImagePostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceCreation;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *location;

@property (weak, nonatomic) IBOutlet UILabel *commentCount;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UILabel *shareCount;

@property (strong, nonatomic) Post *post;

@property (nonatomic, weak) id<NoImagePostCellDelegate> delegate;

@end

@protocol NoImagePostCellDelegate

- (void)noImagePostCell:(NoImagePostCell *)noImagePostCell didTap:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
