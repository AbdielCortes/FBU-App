//
//  PostDetailsViewController.m
//  YellowHouse
//
//  Created by zurken on 7/20/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "PostDetailsViewController.h"
#import "AccountProfileViewController.h"
#import "CreateCommentViewController.h"
#import "PostCell.h"
#import "NoImagePostCell.h"
#import "Comment.h"
#import "CommentCell.h"
#import "NSDate+DateTools.h"
#import <Parse/Parse.h>
@import Parse;

@interface PostDetailsViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, PostCellDelegate, NoImagePostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Pull up refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadPost) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.post.comments.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (self.post.hasImage) {
            PostCell *header = [tableView dequeueReusableCellWithIdentifier:@"PostDetailsCell"];
            [header setPost:self.post];
            header.delegate = self;
            
            return header;
        }
        else {
            NoImagePostCell *header = [tableView dequeueReusableCellWithIdentifier:@"NoImagePostDetailsCell"];
            [header setPost:self.post];
            header.delegate = self;
            
            return header;
        }
    }
    else {
        Comment *comment = self.post.comments[indexPath.row - 1];
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        [cell setComment:comment andReloadTableView:self.tableView];
        return cell;
    }
}

- (void)reloadPost {
    [self.post fetchInBackgroundWithBlock:^(PFObject *updatedPost, NSError *error) {
        if (!error) {
            self.post = (Post *)updatedPost;
            
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

// tapping on a PostCell profile image sends you to that account's profile
- (void)postCell:(nonnull PostCell *)postCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"DetailsProfileSegue" sender:user];
}

// tapping on a NoImagePostCell profile image sends you to that account's profile
- (void)noImagePostCell:(NoImagePostCell *)noImagePostCell didTap:(PFUser *)user {
    [self performSegueWithIdentifier:@"DetailsProfileSegue" sender:user];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue to AccountProfile view
    if ([segue.identifier  isEqual:@"DetailsProfileSegue"]) {
        AccountProfileViewController *accountProfileVC = [segue destinationViewController];
        accountProfileVC.account = (PFUser *)sender;
    } 
    else if ([segue.identifier  isEqual:@"PostCommentSegue"] || [segue.identifier  isEqual:@"NoImagePostCommentSegue"]) {
        CreateCommentViewController *createCommentVC = [segue destinationViewController];
        createCommentVC.post = self.post;
    }
//    else if ([segue.identifier  isEqual:@"CommentProfileSegue"]) {
//        UITableViewCell *tappedCell = sender;
//        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:tappedCell];
//        Comment *comment = self.post.comments[cellIndexPath.row - 1];
//        [comment.author fetchInBackgroundWithBlock:^(PFObject *author, NSError *error) {
//            AccountProfileViewController *accountProfileVC = [segue destinationViewController];
//            accountProfileVC.account = (PFUser *)author;
//        }];
//    }
}

@end
