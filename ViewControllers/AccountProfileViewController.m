//
//  AccountProfileViewController.m
//  YellowHouse
//
//  Created by zurken on 7/17/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "AccountProfileViewController.h"
#import "Post.h"
#import "PostCell.h"
#import "NoImagePostCell.h"
#import "ProfileCell.h"
#import "PostDetailsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface AccountProfileViewController () <UITableViewDelegate, UITableViewDataSource, PostCellDelegate, NoImagePostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *posts;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation AccountProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Loading";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchPosts];
    
    // Pull up refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if (selected) {
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ProfileCell *header = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        [header setAccount:self.account];
        
        return header;
    }
    else {
        Post *post = self.posts[indexPath.row - 1];
        
        UITableViewCell *cell;
        if (post.hasImage) { // post has an image so we use PostCell
            cell = [PostCell new]; // cast cell to PostCell
            cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
            [(PostCell *)cell setPost:post];
            ((PostCell *)cell).delegate = self;
        }
        else { // post doesn't have an image so we use NoImagePostCell
            cell = [NoImagePostCell new]; // cast cell to NoImagePostCell
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoImagePostCell"];
            [(NoImagePostCell *)cell setPost:post];
            ((NoImagePostCell *)cell).delegate = self;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { // if tapped on profile cell, then run deselect animation
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)fetchPosts {
    [self.hud showAnimated:YES]; // show progress pop up
    
    // creates Parse query
    PFQuery *postQuery = [Post query];
    // orders query results by the time they where created
    [postQuery orderByDescending:@"createdAt"];
    // includes the User object of the account that created the post
    [postQuery includeKey:@"author"];
    // filters posts to only include the ones form the current user
    [postQuery whereKey:@"author" equalTo:self.account];
    // limits the amount of posts that the query will get
    postQuery.limit = 10;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = posts; // update posts array
            
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
        else {
            NSLog(@"Error fetching posts: %@", error);
        }
        
        // hide progress pop up
        // outside if/else because we want it to always hide no matter the result
        [self.hud hideAnimated:YES];
    }];
}

// required method for delegate, but its not needed here
- (void)postCell:(nonnull PostCell *)postCell didTap:(nonnull PFUser *)user {
}

// show acticity view controller when the user tapps the share button
- (void)postCell:(PostCell *)postCell share:(NSArray *)activityItems {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil]; 
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

// required method for delegate, but its not needed here
- (void)noImagePostCell:(NoImagePostCell *)noImagePostCell didTap:(PFUser *)user {
}

// show acticity view controller when the user tapps the share button
- (void)noImagePostCell:(NoImagePostCell *)noImagePostCell share:(NSArray *)activityItems {
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"AccountPostDetails"] || [segue.identifier  isEqual: @"AccountNoImageDetails"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[cellIndexPath.row - 1];
        PostDetailsViewController *postDetailsVC = [segue destinationViewController];
        postDetailsVC.post = post;
    }
}

@end
