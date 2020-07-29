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
#import "PostDetailsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface AccountProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *contactInfo;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) NSMutableArray *following;  // array that stores all the accounts that the user is followinf
@property (nonatomic) BOOL isFollowing; // tells us if the user is already following this accounts

@property (strong, nonatomic) NSArray *posts;

@property (strong, nonatomic) MBProgressHUD *hud;

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
    
    [self fetchUserData];
    
    self.followButton.hidden = NO;
    if ([self.account.objectId isEqual:[PFUser currentUser].objectId]) { // user is not allowed to follow themself
        self.followButton.hidden = YES; // hide follow button so that the user can't click it
    }
    else { // user is not looking at their own profile
        self.following = [PFUser currentUser][@"following"]; // get array of accounts that the user is following
        self.isFollowing = NO;
        if (self.following) { // if following array is not null
            // we search through the followed accounts to see if this account is already being followed by the user
            for (PFUser *accountToFollow in self.following) {
                if ([accountToFollow.objectId isEqual:self.account.objectId]) { // user is following this account
                    self.isFollowing = YES;
                    [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
                }
            }
        }
    }
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
    self.username.text = self.account.username;
    self.contactInfo.text = self.account[@"contactInfo"];
    
    self.profileImage.file = self.account[@"profileImage"];
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
    [postQuery whereKey:@"author" equalTo:self.account];
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

// follows the account if the user is not already following it, or unfollows the account
// if the user is already following it
//
// if the user is not following the account, then:
//    if  the following array is not null, then add the account
//    else create an array and add the account
//
// else the user is already following this account:
//    for loop to remove this account from the array
//
// save following array in database
- (IBAction)tappedFollow:(id)sender {
    PFUser *currentUser = [PFUser currentUser];

    if (!self.isFollowing) { // if user is not following this account
        if (self.following) { // if following arra is not null (array is null when this is the first account the user follows)
            [self.following addObject:self.account]; // add acount to array
            currentUser[@"following"] = self.following; // send array to user
        }
        else { // this is the first account the user is following so the following array is null
            NSMutableArray *newArray = [[NSMutableArray alloc] init]; // create array
            [newArray addObject:self.account]; // add account
            currentUser[@"following"] = newArray; // send array to user
        }
        
        self.isFollowing = YES;
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal]; // change button text
    }
    else {
        NSMutableArray *withoutAccount = [[NSMutableArray alloc] init]; // create new array to store all accounts except this one
        for (PFUser *currentAccount in self.following) { // we search through the followed accounts to find this account
            // if account is not equal to the account that we want to remove
            if (![currentAccount.objectId isEqual:self.account.objectId]) {
                [withoutAccount addObject:currentAccount]; // add account ot new array
            }
        }
        
        self.following = withoutAccount; // update following array
        currentUser[@"following"] = withoutAccount; // send new array to user
        self.isFollowing = NO;
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal]; // change button text
    }
    
    // save the changes to parse
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (error) {
            NSLog(@"Error occured while changing user info: %@", error);
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"AccountPostDetails"] || [segue.identifier  isEqual: @"AccountNoImageDetails"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[cellIndexPath.row];
        PostDetailsViewController *postDetailsVC = [segue destinationViewController];
        postDetailsVC.post = post;
    }
}

@end
