//
//  LocationViewController.h
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//
//  View controller that uses the Foursquare API to get places near the user's current location.
//  Shows a table view with a search bar, where the user can type names of places near them. Tapping
//  on location table view cell takes you back to the map view and shows a pin of the place that was selected.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LocationViewControllerDelegate;

@interface LocationViewController : UIViewController

@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

@property (weak, nonatomic) id<LocationViewControllerDelegate> delegate;

@end

// delegate to send location back to the map view
@protocol LocationViewControllerDelegate

- (void)locationViewController:(LocationViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude withName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
