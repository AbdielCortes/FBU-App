//
//  MapViewController.m
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "MapViewController.h"
#import "LocationViewController.h"
#import <MapKit/MapKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface MapViewController () <MKMapViewDelegate, LocationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *tagLocationButton;

@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSNumber *currentLatitude;
@property (strong, nonatomic) NSNumber *currentLongitude;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Loading";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    [self getCurrentLocation];
    // San Francisco: 37.783333, -122.416667
    // New York City: 40.73, -73.99
    
    self.tagLocationButton.hidden = NO;
}

-(void)getCurrentLocation {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.hud showAnimated:YES]; // show progress pop up
    
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
         if (!error) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             CLLocationCoordinate2D coordinates = placemark.location.coordinate;
             self.currentLatitude = @(coordinates.latitude);
             self.currentLongitude = @(coordinates.longitude);
             
             MKCoordinateRegion currentLocation = MKCoordinateRegionMake(CLLocationCoordinate2DMake([self.currentLatitude doubleValue], [self.currentLongitude doubleValue]), MKCoordinateSpanMake(0.7, 0.7));
             [self.mapView setRegion:currentLocation animated:false];
         }
         else {
             NSLog(@"Geocode failed with error %@", error);
         }
        
        // hide progress pop up
        // outside if/else because we want it to always hide no matter the result
        [self.hud hideAnimated:YES];
     }];
}

- (IBAction)tappedConfirm:(id)sender {
    // pass data usign delegate
    [self.delegate mapViewController:self withLocationName:self.locationName];
    
    // return segue
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationViewController:(LocationViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude withName:name{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = name;
    self.locationName = name;
    [self.mapView addAnnotation:annotation];
    self.tagLocationButton.hidden = YES;
    
    [self.navigationController popToViewController:self animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"LocationSegue"]) {
        LocationViewController *locationVC = [segue destinationViewController];
        locationVC.delegate = self;
        locationVC.latitude = self.currentLatitude;
        locationVC.longitude = self.currentLongitude;
    }
}

@end
