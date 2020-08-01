//
//  CommentCell.m
//  YellowHouse
//
//  Created by zurken on 7/31/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setComment:(Comment *)comment andReloadTableView:(UITableView *)tableView {
    _comment = comment;
    
    // the post only stores the pointer to the comment so we need to fetch the object
    [comment fetchInBackgroundWithBlock:^(PFObject *com, NSError *error) {
        if (!error) {
            self.commentText.text = comment.text;
            
            // the comment only stores the pointer to the author so we need to fetch the object
            [comment.author fetchInBackgroundWithBlock:^(PFObject *author, NSError *error) {
                self.username.text = comment.author.username;

                self.profileImage.file = comment.author[@"profileImage"];
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
                self.profileImage.clipsToBounds = YES;
                [self.profileImage loadInBackground];
                
                [tableView reloadData];
            }];
        }
        else {
           NSLog(@"Error fetching comment: %@", error);
        }
    }];
}

@end
