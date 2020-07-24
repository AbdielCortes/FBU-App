//
//  MapViewController.h
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//
//  This view uses the iOSMapKit to show a map of the users current location and a pin on the
//  location that the user selected.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController <CLLocationManagerDelegate> {
    // create objects to get the user's current location
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (weak, nonatomic) id<MapViewControllerDelegate> delegate;

@end

// delegate to send the tagged location back to the create post view
@protocol MapViewControllerDelegate

- (void)mapViewController:(MapViewController *)controller withLocationName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
