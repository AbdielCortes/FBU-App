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

@interface MapViewController () <MKMapViewDelegate, LocationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *tagLocationButton;

@property (strong, nonatomic) NSString *locationName;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
//    40.73, -73.99
    MKCoordinateRegion nyc = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:nyc animated:false];
    
    self.tagLocationButton.hidden = NO;
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
    }
}

@end
