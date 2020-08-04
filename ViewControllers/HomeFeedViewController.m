//
//  HomeFeedViewController.m
//  YellowHouse
//
//  Created by zurken on 7/13/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "HomeFeedViewController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "PostDetailsViewController.h"
#import "Post.h"
#import "PostCell.h"
#import "NoImagePostCell.h"
#import "AccountProfileViewController.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface HomeFeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PostCellDelegate, NoImagePostCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL isMoreDataLoading; // is a Parse network request running?
@property (assign, nonatomic) NSInteger querieLimit; // how many posts we're getting from parse
@property (assign, nonatomic) BOOL morePosts; // determines wether we have already gotten all the posts from parse
@property (assign, nonatomic) BOOL refreshed; // determines when the user called refreshPosts

@property (strong, nonatomic) NSArray *posts;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Loading";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    self.querieLimit = 10; // amount of posts we want to load for the first querie
    self.morePosts = YES; // initiliazing morePosts to YES so that scrollViewDidScroll can call fetchPosts
    [self fetchPosts];
    
    // Pull up refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    self.refreshed = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if (selected) {
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = self.posts[indexPath.row];
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // we first check isMoreDataLoading because we don't want to call this function again until the previous call is done
     if (!self.isMoreDataLoading) {
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if (scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = YES;
            
            if (self.morePosts) { // if there are more posts to be found
                [self fetchPosts];
            }
        }
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
    // filters posts to only include the ones form accounts that the user is following
    [postQuery whereKey:@"author" containedIn:[PFUser currentUser][@"following"]];
    // limits the amount of posts that the query will get
    postQuery.limit = self.querieLimit;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            if (self.refreshed) { // if refresh was called
                self.posts = posts; // update posts array
                self.refreshed = NO; // reset it so that refresh can be called again
            }
            else if (self.posts.count == posts.count) { // if fetch post got called but it didn'f find any extra posts
                self.morePosts = NO; // sets more posts to NO so that scrollViewDidScroll wont call fetch posts
            }
            else { // else fetch posts found more posts
                self.morePosts = YES; // since this time we found more posts, then we can keep searching
                self.posts = posts; // update posts array
            }
            
            self.isMoreDataLoading = NO; // makes it so that scrollViewDidScroll can be called again when necessary
            self.querieLimit += 10; // increases querie limit so that fetch posts gets more posts
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

- (void)refreshPosts {
    // raise flag saying that refreshPosts was called
    self.refreshed = YES;
    // resets querie limit to 10 so that it wont load the entire feed again, but just the first 10 posts
    self.querieLimit = 10;
    // call fetch posts to do the actual network call
    [self fetchPosts];
}

// logs the user out and sends them to the login screen
- (IBAction)tappedLogOut:(id)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootNavControl"];
    sceneDelegate.window.rootViewController = loginViewController;
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) { }];
}

// tapping on a PostCell profile image sends you to that account's profile
- (void)postCell:(nonnull PostCell *)postCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"AccountProfileSegue" sender:user];
}

// show acticity view controller when the user tapps the share button
- (void)postCell:(PostCell *)postCell share:(NSArray *)activityItems {
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

// tapping on a NoImagePostCell profile image sends you to that account's profile
- (void)noImagePostCell:(NoImagePostCell *)noImagePostCell didTap:(PFUser *)user {
    [self performSegueWithIdentifier:@"AccountProfileSegue" sender:user];
}

// show acticity view controller when the user tapps the share button
- (void)noImagePostCell:(NoImagePostCell *)noImagePostCell share:(NSArray *)activityItems {
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue to post details view
    if ([segue.identifier  isEqual: @"PostCellDetails"] || [segue.identifier  isEqual: @"NoImagePostCellDetails"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[cellIndexPath.row];
        PostDetailsViewController *postDetailsVC = [segue destinationViewController];
        postDetailsVC.post = post;
    }
    // segue to account profile view
    else if ([segue.identifier  isEqual: @"AccountProfileSegue"]) {
        AccountProfileViewController *accountProfileVC = [segue destinationViewController];
        accountProfileVC.account = (PFUser *)sender;
    }
}

@end
