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
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
@import Parse;

@interface PostDetailsViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, PostCellDelegate, NoImagePostCellDelegate>

@property (strong, nonatomic) NSArray *comments;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Loading Comments";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    [self fetchComments];
    
    // Pull up refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if (selected) {
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count + 1;
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
        Comment *comment = self.comments[indexPath.row - 1];
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        [cell setComment:comment];
        
        return cell;
    }
}

- (void)fetchComments {
    [self.hud showAnimated:YES]; // show progress pop up
    // create query for comments
    PFQuery *commentsQuery = [Comment query];
    // only get comments that belong to this post
    [commentsQuery whereKey:@"parentPost" equalTo:self.post.objectId];
    // order them by the time they were created
    [commentsQuery orderByAscending:@"createdAt"];
    // include author object
    [commentsQuery includeKey:@"author"];
    // fetch them from parse
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable comments, NSError * _Nullable error) {
        if (comments) {
            self.comments = comments;
            
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
        else if (error) {
            NSLog(@"Error fetching comments: %@", error);
        }
        
        // hide progress pop up
        // outside if/else because we want it to always hide no matter the result
        [self.hud hideAnimated:YES];
    }];
}

- (void)reloadPost {
    [self.post fetchInBackgroundWithBlock:^(PFObject *updatedPost, NSError *error) {
        if (!error) {
            self.post = (Post *)updatedPost;
        }
    }];
}

- (void)refreshData {
    [self reloadPost];
    [self fetchComments];
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
    // segue to AccountProfile view from tapping on profile image
    if ([segue.identifier  isEqual:@"DetailsProfileSegue"]) {
        AccountProfileViewController *accountProfileVC = [segue destinationViewController];
        accountProfileVC.account = (PFUser *)sender;
    }
    // segue to create post
    else if ([segue.identifier  isEqual:@"PostCommentSegue"] || [segue.identifier  isEqual:@"NoImagePostCommentSegue"]) {
        CreateCommentViewController *createCommentVC = [segue destinationViewController];
        createCommentVC.post = self.post;
    }
    // segue to AccountProfile view from tapping a comment
    else if ([segue.identifier  isEqual:@"CommentProfileSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:tappedCell];
        Comment *comment = self.comments[cellIndexPath.row - 1];
        AccountProfileViewController *accountProfileVC = [segue destinationViewController];
        accountProfileVC.account = comment.author;
    }
}

@end
