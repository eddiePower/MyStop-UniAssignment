//  ShowStopMapViewController.h                                                
//  MyStopMonitor

//  This class is used to create a view controller to show the currently
//  set station in an alarm in detail that includes a map of its location
//  using a MKMapView, and details such as stop type, annotation with station name
//  and buttons that will soon hold info on train times and stop parking or mykey detail
//  This class is a subclass of the UIViewController, and uses the MKMapViewDelegate protocol
//  to recieve feedback from the mapView and location manager to track user location.
 
//  Created by Eddie Power on 7/05/2014.
//  Copyright (c) 2014 Eddie Power.
//  All rights reserved.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Station.h"
#import "StopAnnotation.h"

@interface ShowStopMapViewController : UIViewController <MKMapViewDelegate>

//Station Detail output.
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationTypeLabel;
//station mapView output.

@property (weak, nonatomic) IBOutlet UILabel *stationDistanceLabel;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, readonly) MKMapRect boundingMapRect;
@property (nonatomic) CLLocationCoordinate2D mapCoordinate;

//Station object passed from alarm list to display
@property (strong, nonatomic) Station* mapStation;

@end
