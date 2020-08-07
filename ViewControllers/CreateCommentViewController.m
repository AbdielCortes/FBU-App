//
//  CreateCommentViewController.m
//  YellowHouse
//
//  Created by zurken on 7/31/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "CreateCommentViewController.h"
#import "Comment.h"
#import "Utilities.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <UITextView+Placeholder.h>

@interface CreateCommentViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (nonatomic) int commentTextLimit;
@property (nonatomic) BOOL isOverTextLimit;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation CreateCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Commenting";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    self.commentButton.layer.cornerRadius = self.commentButton.frame.size.height / 2;
    self.commentButton.backgroundColor = [UIColor colorWithRed:1 green:0.92 blue:0.38 alpha:1];
    
    self.commentTextView.placeholder = @"Write comment";
    self.commentTextView.placeholderColor = [UIColor lightGrayColor];
    self.commentTextView.layer.cornerRadius = 5.0f;
    self.commentTextView.delegate = self;
    self.commentTextLimit = 250;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.commentTextView) { // editing caption
        // get text that's currently in text view
        NSString *currentText = [self.commentTextView.text stringByReplacingCharactersInRange:range withString:text];
        if (currentText.length > self.commentTextLimit) { // text is longer than the character limit
            self.commentTextView.backgroundColor = [UIColor colorWithRed:1 green:0.47 blue:0.47 alpha:0.8];
            self.isOverTextLimit = YES;
        }
        else {
            self.commentTextView.backgroundColor = [UIColor systemGray6Color];
            self.isOverTextLimit = NO;
        }
    }
    
    return YES;
}

- (IBAction)tappedComment:(id)sender {
    [self.hud showAnimated:YES]; // show progress pop up
    
    if ([self.commentTextView.text isEqualToString:@""]) { // coment text view has no text
        [Utilities showOkAlert:self withTitle:@"No Comment" withMessage:@"In order to create a comment you must type something."];
        [self.hud hideAnimated:YES];
    }
    else if (self.isOverTextLimit) {
        [Utilities showOkAlert:self withTitle:@"Over Text Limit" withMessage:@"Your comment is exceeding the text limit."];
        [self.hud hideAnimated:YES];
    }
    else {
        Comment *newComment = [Comment postComment:self.commentTextView.text withParentPost:self.post.objectId withCompletion:^(BOOL succeded, NSError *error) {
            if (succeded) {
                self.commentTextView.text = @"";
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else {
                NSLog(@"Error when posting: %@", error);
            }
            
            // hide progress pop up
            // outside if/else because we want it to always hide no matter the result
            [self.hud hideAnimated:YES];
        }];
        
        // add comment to post comments
        [self.post.comments addObject:newComment];
        self.post[@"comments"] = self.post.comments;
        // save the changes to parse
        [self.post saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
            if (error) {
                NSLog(@"Error occured while changing user info: %@", error);
            }
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
