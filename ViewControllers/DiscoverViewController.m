//
//  DiscoverViewController.m
//  YellowHouse
//
//  Created by zurken on 7/27/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "DiscoverViewController.h"
#import "AccountCell.h"
#import "AccountProfileViewController.h"
#import <Parse/Parse.h>

@interface DiscoverViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray *users; // all the users
@property (strong, nonatomic) NSArray *results; // the users that match the search query

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if (selected) {
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
    [cell setAccount:self.results[indexPath.row]];
    
    return cell;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // get all the users from Parse
    [self fetchAllUsers];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    if (newText.length >= 3) { // only start searching when the user has typed 3 or more characters
        [self searchForUser:searchBar.text];
    }
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchForUser:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)fetchAllUsers {
    PFQuery *accountQuery = [PFQuery queryWithClassName:@"_User"];
    
    // only include this fields when getting the user
    [accountQuery selectKeys:@[@"username", @"profileImage", @"contactInfo"]];
    
    // get all the users from Parse
    [accountQuery findObjectsInBackgroundWithBlock:^(NSArray *accounts, NSError *error)  {
        if (!error) {
            if (accounts) {
                self.users = accounts;
            }
        }
        else {
            NSLog(@"Error fetching accounts: %@", error);
        }
    }];
}

- (void)searchForUser:(NSString *)username {
    // we make everything lower case so that search is not case sensitive
    NSString *lowercaseQuery = [username lowercaseString];
    // create array to store the users that match the query
    NSMutableArray *matchingUsers = [[NSMutableArray alloc] init];
    
    // linear search through all the users
    // we want to make sure that we look at all the users, because we're making sure that
    // we check if the username contains the lowercaseQuery
    // Example: lowercaseQuery = ron,
    // we would find: Ronald, bronze, jerryRon
    for (PFUser *user in self.users) {
        // change username to lowercase
        NSString *lowercaseName = [user.username lowercaseString];
        // check if the query is a prefix for the username first
        if ([lowercaseName hasPrefix:lowercaseQuery]) {
            [matchingUsers addObject:user];
        }
        // check if the username contains the query
        else if ([lowercaseName containsString:lowercaseQuery]) {
            [matchingUsers addObject:user];
        }
    }
    // update results array
    self.results = matchingUsers;
    // reload table view to show new data
    [self.tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"SearchAccountSegue"]) {
        AccountProfileViewController *accountProfileVC = [segue destinationViewController];
        accountProfileVC.account = ((AccountCell *)sender).account;
    }
}

@end
