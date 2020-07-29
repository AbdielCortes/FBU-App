//
//  UserProfileViewController.m
//  YellowHouse
//
//  Created by zurken on 7/16/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "UserProfileViewController.h"
#import "PostCell.h"
#import "NoImagePostCell.h"
#import "PostDetailsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
@import Parse;

@interface UserProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *contactInfo;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *posts;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Loading";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    [self fetchPosts];

    [self fetchUserData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // call fetch user here so that when the user changes his info and comes back
    // the viewl will reload the user data
    [self fetchUserData];
    
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
    }
    else { // post doesn't have an image so we use NoImagePostCell
        cell = [NoImagePostCell new]; // cast cell to NoImagePostCell
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoImagePostCell"];
        [(NoImagePostCell *)cell setPost:post];
    }
    
    return cell;
}

- (void)fetchUserData {
    PFUser *user = [PFUser currentUser];
    
    self.username.text = user.username;
    self.contactInfo.text = user[@"contactInfo"];
    
    self.profileImage.file = user[@"profileImage"];
    self.profileImage.layer.cornerRadius = 10.0f;
    [self.profileImage loadInBackground];
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
    [postQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    // limits the amount of posts that the query will get
    postQuery.limit = 10;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.posts = posts; // update posts array
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error fetching posts: %@", error);
        }
        
        // hide progress pop up
        // outside if/else because we want it to always hide no matter the result
        [self.hud hideAnimated:YES];
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"PostDetails"] || [segue.identifier  isEqual: @"NoImageDetails"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[cellIndexPath.row];
        PostDetailsViewController *postDetailsVC = [segue destinationViewController];
        postDetailsVC.post = post;
    }
}

@end
