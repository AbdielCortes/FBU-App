//
//  CommentCell.h
//  YellowHouse
//
//  Created by zurken on 7/31/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import <Parse/Parse.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *commentText;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@property (strong, nonatomic) Comment *comment;

- (void)setComment:(Comment *)comment andReloadTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
