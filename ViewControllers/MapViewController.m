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
@property (strong, nonatomic) NSNumber *searchLatitude;
@property (strong, nonatomic) NSNumber *searchLongitude;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    // add long press gesture recognizer to map
    UILongPressGestureRecognizer *mapLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPinLocation:)];
    mapLongPress.minimumPressDuration = 0.7;
    [self.mapView addGestureRecognizer:mapLongPress];
    [self.mapView setUserInteractionEnabled:YES];
    
    // Create progress pop up
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.label.text = @"Loading";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.hud];
    
    [self getCurrentLocation];
}

// uses CLLocation manager to get the user's current location
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
             self.searchLatitude = @(coordinates.latitude);
             self.searchLongitude = @(coordinates.longitude);
             
             MKCoordinateRegion currentLocation = MKCoordinateRegionMake(CLLocationCoordinate2DMake([self.currentLatitude doubleValue], [self.currentLongitude doubleValue]), MKCoordinateSpanMake(0.7, 0.7));
             [self.mapView setRegion:currentLocation animated:YES];
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
    // pass data to create post view usign delegate
    [self.delegate mapViewController:self withLocationName:self.locationName];
    
    // return segue
    [self.navigationController popViewControllerAnimated:YES];
}

// drops pin on selected location
- (void)locationViewController:(LocationViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude withName:name{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = name;
    self.locationName = name;
    [self.mapView addAnnotation:annotation];
    
    // center map on selected location
    MKCoordinateRegion currentLocation = MKCoordinateRegionMake(CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude), MKCoordinateSpanMake(0.7, 0.7));
    [self.mapView setRegion:currentLocation animated:YES];
    
    [self.navigationController popToViewController:self animated:YES];
}

// long pressing drops a pin in that location and sets that as the location for searching near by places
- (void)longPressPinLocation:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    // remove previous annotations
    [self.mapView removeAnnotations:self.mapView.annotations];
    // get coordinates from tapped location
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    // create annotation to show what location was tapped
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = @"Search Near Here";
    // set current location coordinates to tapped location
    self.searchLatitude = @(coordinate.latitude);
    self.searchLongitude = @(coordinate.longitude);
    // add anotation to map
    [self.mapView addAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // tapped on the Search Near Here pin
    if ([view.annotation.title isEqualToString:@"Search Near Here"]) {
        // remove annotation from map
        [self.mapView removeAnnotation:view.annotation];
        // set search coordinates back to current location
        self.searchLatitude = self.currentLatitude;
        self.searchLongitude = self.currentLongitude;
    }
    else { // tapped a location pin
        // set locationName back to nil so that create post knows that it doesen't have a location
        self.locationName = nil;
    }
    
    // remove annotation from map
    [self.mapView removeAnnotation:view.annotation];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue to location view
    if ([segue.identifier  isEqual: @"LocationSegue"]) {
        LocationViewController *locationVC = [segue destinationViewController];
        locationVC.delegate = self;
        locationVC.latitude = self.searchLatitude;
        locationVC.longitude = self.searchLongitude;
        
        // remove previous annotation
        for (MKPointAnnotation *annotation in [self.mapView annotations]) {
            if (![annotation.title isEqualToString:@"Search Near Here"]) { // don't remove search near hear annotation
                [self.mapView removeAnnotation:annotation];
            }
        }
    }
}

@end
