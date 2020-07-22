//
//  MapViewController.h
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (weak, nonatomic) id<MapViewControllerDelegate> delegate;

@end

@protocol MapViewControllerDelegate

- (void)mapViewController:(MapViewController *)controller withLocationName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
