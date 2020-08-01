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
#import "Comment.h"
#import "CommentCell.h"
#import "NSDate+DateTools.h"
#import <Parse/Parse.h>
@import Parse;

@interface PostDetailsViewController () <PostDetailsDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceCreation;
@property (weak, nonatomic) IBOutlet UILabel *creationDate;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *priceAndShipping;
@property (weak, nonatomic) IBOutlet UILabel *contactInfo;

@property (weak, nonatomic) IBOutlet UILabel *commentCount;

@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (nonatomic) BOOL liked; // tells us if the user has already liked this post

@property (weak, nonatomic) IBOutlet UILabel *shareCount;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet PFImageView *postImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Gesture recognizer for tapping on profile image
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedProfileImage:)];
    [self.profileImage addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
    
    // set up scroll view for image zooming
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = CGSizeMake(450, 450);
    self.scrollView.delegate = self;
    self.scrollView.layer.cornerRadius = 5.0f;
    
    self.delegate = self;
    
    // Setting labels and images to their proper values
    self.username.text = self.post.author.username;
    self.caption.text = self.post.caption;
    // converts date into a string that says how long ago the post was created
    // example: "2 hours ago"
    self.timeSinceCreation.text = self.post.createdAt.timeAgoSinceNow;
    
    // use formatter to show the date when the post was created
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.creationDate.text = [formatter stringFromDate:self.post.createdAt];
    
    self.profileImage.file = self.post.author[@"profileImage"];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage loadInBackground];
    
    if (self.post.hasImage) { // post has an image
        self.postImage.layer.cornerRadius = 5.0f;
        // gets image from parse
        [self.post[@"image"] getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                self.postImage.image = image;
            }
            else {
                NSLog(@"error loading image: %@", error);
            }
        }];
    }
    else { // post dosen't have an image
        [self.scrollView removeFromSuperview]; // remove image scroll view from view
    }
    
    self.location.text = self.post.locationName;;
    
    if (self.post.isSellPost) { // if post is a sell post
        SellPost *sellPost = (SellPost *)self.post;
        self.priceAndShipping.text = [NSString stringWithFormat:@"$%@ + $%@ shipping", sellPost.price, sellPost.shippingCost];
        self.contactInfo.text = sellPost.contactInfo;
    }
    else {
        self.priceAndShipping.text = @"";
        self.contactInfo.text = @"";
    }
    
    self.likeCount.text = [NSString stringWithFormat:@"%lu", self.post.userLike.count];
    [self checkIfLiked];
    
    self.commentCount.text = [NSString stringWithFormat:@"%lu", self.post.comments.count];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Pull up refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadPost) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.post.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = self.post.comments[indexPath.row];
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    [cell setComment:comment];
    
    return cell;
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.postImage;
}

- (void)checkIfLiked {
    self.liked = NO;
    for (PFUser *user in self.post.userLike) {
        // if current user is inside this post's userLike array
        if ([user.objectId isEqual:[PFUser currentUser].objectId]) {
            self.liked = YES;
        }
    }
    
    // set like button to correct state depending on if its liked or not
    if (self.liked) {
        self.likeButton.selected = YES;
    }
    else {
        self.likeButton.selected = NO;
    }
}

- (IBAction)tappedLike:(id)sender {
    if (self.liked) { // unliking
        // set button to look default
        self.likeButton.selected = NO;
        
        // remove current user from userLike array
        NSMutableArray *withoutCurrentUser = [[NSMutableArray alloc] init]; // create new array to store all accounts except this one
        for (PFUser *currentAccount in self.post.userLike) { // we search through the followed accounts to find this account
            // if account is not equal to the currentUser
            if (![currentAccount.objectId isEqual:[PFUser currentUser].objectId]) {
                [withoutCurrentUser addObject:currentAccount]; // add account ot new array
            }
        }
        self.post.userLike = withoutCurrentUser;
        self.post[@"userLike"] = withoutCurrentUser;
        
        // update like count label
        self.likeCount.text = [NSString stringWithFormat:@"%lu", self.post.userLike.count];
        // update liked boolean value
        self.liked = NO;
    }
    else { // liking
        // set button to look selected
        self.likeButton.selected = YES;
        // add current user to userLike array
        [self.post.userLike addObject:[PFUser currentUser]];
        self.post[@"userLike"] = self.post.userLike;
        // update like count label
        self.likeCount.text = [NSString stringWithFormat:@"%lu", self.post.userLike.count];
        // update liked boolean value
        self.liked = YES;
    }
    
    // save the changes to parse
    [self.post saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (error) {
            NSLog(@"Error occured while changing user info: %@", error);
        }
    }];
}

// send post to AccountProfile when the profile image was tapped
- (void)tappedProfileImage:(UITapGestureRecognizer *)sender {
    [self.delegate postDetails:self didTap:self.post.author];
}

- (void)postDetails:(PostDetailsViewController *)postDetails didTap:(PFUser *)user {
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
    else if ([segue.identifier  isEqual:@"CreateCommentSegue"]) {
        CreateCommentViewController *createCommentVC = [segue destinationViewController];
        createCommentVC.post = self.post;
    }
}

@end
