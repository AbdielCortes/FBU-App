//
//  PostDetailsViewController.m
//  YellowHouse
//
//  Created by zurken on 7/20/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "PostDetailsViewController.h"
#import "AccountProfileViewController.h"
#import "NSDate+DateTools.h"
#import <Parse/Parse.h>
@import Parse;

@interface PostDetailsViewController () <PostDetailsDelegate>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceCreation;
@property (weak, nonatomic) IBOutlet UILabel *creationDate;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *priceAndShipping;
@property (weak, nonatomic) IBOutlet UILabel *contactInfo;

@property (weak, nonatomic) IBOutlet UILabel *commentCount;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UILabel *shareCount;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet PFImageView *postImage;

@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Gesture recognizer for tapping on profile image
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedProfileImage:)];
    [self.profileImage addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
    
    self.delegate = self;
    
    // Setting labels and images to their proper values
    self.username.text = self.post.author.username;
    self.caption.text = self.post.caption;
    self.timeSinceCreation.text = self.post.createdAt.timeAgoSinceNow;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.creationDate.text = [formatter stringFromDate:self.post.createdAt];
    
    self.profileImage.file = self.post.author[@"profileImage"];
    [self.profileImage loadInBackground];
    
    if (self.post.hasImage) { // post has an image
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
        [self.postImage removeFromSuperview]; // remove image view from view
    }
    
    self.location.text = @"";
    
    if (self.post.isSellPost) { // if post is a sell post
        SellPost *sellPost = (SellPost *)self.post;
        self.priceAndShipping.text = [NSString stringWithFormat:@"$%@ + $%@ shipping", sellPost.price, sellPost.shippingCost];
        self.contactInfo.text = sellPost.contactInfo;
    }
    else {
        self.priceAndShipping.text = @"";
        self.contactInfo.text = @"";
    }
}

- (void)tappedProfileImage:(UITapGestureRecognizer *)sender {
    [self.delegate postDetails:self didTap:self.post.author];
}

- (void)postDetails:(PostDetailsViewController *)postDetails didTap:(PFUser *)user {
    [self performSegueWithIdentifier:@"DetailsProfileSegue" sender:user];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"DetailsProfileSegue"]) {
        AccountProfileViewController *accountProfileVC = [segue destinationViewController];
        accountProfileVC.account = (PFUser *)sender;
    }
}

@end
