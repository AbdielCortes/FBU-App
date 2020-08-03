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
@property (assign, nonatomic) BOOL searchWasTapped; // tells us if the search button was tapped

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    // get all the users from Parse
    [self fetchAllUsers];
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
    self.searchWasTapped = NO;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    if (newText.length >= 3) { // only start searching when the user has typed 3 or more characters
        // when the user is typying text we use fetchUsersWithQuery because its faster
        [self fetchUsersWithQuery:newText];
    }
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // raise flag, because searchBar:shouldChangeTextInRange:replacementText is called before this method
    self.searchWasTapped = YES;
    // when the user presses the search button we use searchForUser because it is more thorough
    [self searchForUser:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)fetchUsersWithQuery:(NSString *)query {
    // dont search if the search bar is empty
    // searching for an empty string will return all the users
    if (query.length > 0) {
        PFQuery *accountQuery = [PFQuery queryWithClassName:@"_User"];
        [accountQuery whereKey:@"username" hasPrefix:query];

        // only include this fields when getting the user
        [accountQuery selectKeys:@[@"username", @"profileImage", @"contactInfo"]];

        [accountQuery findObjectsInBackgroundWithBlock:^(NSArray *accounts, NSError *error)  {
            if (!error) {
                // don't update array if searchWasTapped because we wan to use the results from searchForUser
                if (accounts && !self.searchWasTapped) {
                    self.results = accounts;
                    [self.tableView reloadData];
                }
            }
            else {
                NSLog(@"Error fetching accounts: %@", error);
            }
        }];
    }
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
        // check if the username contains the query
        if ([lowercaseName containsString:lowercaseQuery]) {
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
