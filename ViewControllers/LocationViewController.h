//
//  LocationViewController.h
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LocationViewControllerDelegate;

@interface LocationViewController : UIViewController

@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

@property (weak, nonatomic) id<LocationViewControllerDelegate> delegate;

@end

@protocol LocationViewControllerDelegate

- (void)locationViewController:(LocationViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude withName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
