//
//  MapViewController.h
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController

@property (weak, nonatomic) id<MapViewControllerDelegate> delegate;

@end

@protocol MapViewControllerDelegate

- (void)mapViewController:(MapViewController *)controller withLocationName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
