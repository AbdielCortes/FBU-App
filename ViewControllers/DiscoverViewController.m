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

@property (strong, nonatomic) NSArray *accounts;

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
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
    [cell setAccount:self.accounts[indexPath.row]];
    
    return cell;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    if (newText.length >= 3) { // only start searching when the user has typed 3 or more characters
        [self fetchUsersWithQuery:newText];
    }
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self fetchUsersWithQuery:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)fetchUsersWithQuery:(NSString *)query {
    // dont search if the search bar is empty
    // searching for an empty string will return all the users
    if (query.length > 0) {
        PFQuery *accountQuery = [PFQuery queryWithClassName:@"_User"];
        [accountQuery whereKey:@"username" hasPrefix:query];
        //[accountQuery whereKey:@"username" matchesText:query];
        
        // only include this fields when getting the user
        [accountQuery selectKeys:@[@"username", @"profileImage", @"contactInfo"]];
        
        [accountQuery findObjectsInBackgroundWithBlock:^(NSArray *accounts, NSError *error)  {
            if (!error) {
                if (accounts) {
                    self.accounts = accounts;
                    [self.tableView reloadData];
                }
            }
            else {
                NSLog(@"Error fetching accounts: %@", error);
            }
        }];
    }
    else {
        self.accounts = nil;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"SearchAccountSegue"]) {
        AccountProfileViewController *accountProfileVC = [segue destinationViewController];
        accountProfileVC.account = ((AccountCell *)sender).account;
    }
}

@end
