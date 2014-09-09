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

#import "ShowStopMapViewController.h"
#import "StopAnnotation.h"

@implementation ShowStopMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //customise the view background with an image, this will not stay a perminant feature as i am no
    // good at UI design.
    //[[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mapBg"]]];
    
    // Create userDefaults store for retrieving radius values for overlays
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //MapView Configuration to show user location when near alarm region on map
    self.mapView.showsUserLocation = YES;
    
    //set some labels with station information
    // will expand this to have ticket information, and parking locations in future updates
    self.stationNameLabel.text = self.mapStation.stationName;
    self.stationTypeLabel.text = [NSString stringWithFormat:@"Transport Type: %@", self.mapStation.stationStopType];
   
    //Set the mapView Delegate to return to itself for annotations.
    self.mapView.delegate = self;
   
    //retrieve the alertRadius value
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
    
    //store it as a double number
    double tempRadius = tempString.doubleValue;
    
    //set up a station 2D coord.
    CLLocationCoordinate2D center;
    center.latitude = [self.mapStation.stationLatitude doubleValue];
    center.longitude = [self.mapStation.stationLongitude doubleValue];
    
    //Calculate the distance from user to station
    //set up and grab the user location from locManager.
    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    [locManager startUpdatingLocation];
    
    //display the current distance from the user to the station selected.
    self.stationDistanceLabel.text = [NSString stringWithFormat:@"Distance from you: %.2f km's", [self kilometersfromPlace: locManager.location.coordinate andToPlace: center]];

    //stop monitoring user local for now.
    [locManager stopUpdatingLocation];
    
    
    //create a mapPoint for the mapRect creation
    MKMapPoint pt = MKMapPointForCoordinate(center);
    //set width in a double variable by using an eqiasion
    double w = MKMapPointsPerMeterAtLatitude(center.latitude) * (tempRadius * 2);
    MKMapRect mapRect = MKMapRectMake(pt.x - w/2.0, pt.y - w/2.0, w, w);
    //set visible mapRect and animate it to show zooming on mapView
    [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(30, 0, 25, 0) animated: YES];

    //initalize annotation for Stop with title, coord's
    //  and subtitle used for display only - user visulisation of station.
    StopAnnotation *item = [[StopAnnotation alloc] initWithTitle:self.mapStation.stationName aCoord:center andSubtitle:self.mapStation.stationStopType];

    //Add annotation array to the map
    [self.mapView addAnnotation: item];
   
    //overridden method below, adds custom pin and callout.
    [self.mapView viewForAnnotation: item];
    
        
    //create map overlay in circle shape and use alert radius from alarm class
    // as circle radius
    MKCircle *circle = [MKCircle circleWithCenterCoordinate: center radius: tempRadius];
    
    
    [self.mapView addOverlay: circle];
    
    //FUTURE ADD TO MARKER THE MYKI OUTLET STATUS AND PARKING STATUS OF STATIONS.
    //Maybe in the call outs or with seperate annotations
}

//MapView delegate
//Draw region overlay on map
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    //Create Circle renderer object to draw the circle overlay on the mapView layers
    MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
    //set line colour to blue
    circleR.strokeColor = [UIColor blueColor];
    //set fill colour to blue
    circleR.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
    //set line width to 3
    circleR.lineWidth = 3;
    
    return circleR;
}

//draw the annotation on the mapView passed in.
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        //may add code here to show user location by reverse geo lookup in future when location is tapped
        return nil;
    }

    // handle my custom annotation may add others for bus/train/tram or other use.
    // for station or stop annotation
    if ([annotation isKindOfClass:[StopAnnotation class]])
    {
        //set static string for annotation identifier.
        static NSString *StopAnnotationIdentifier = @"StopAnnotation";
        
        //create a pinView to show the pin for the stop annotation
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier: StopAnnotationIdentifier];
       
        //If there are no created pinViews
        if (pinView == nil)
        {
            //if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView =
            [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: StopAnnotationIdentifier];
            
            //Customize the pin view looks.
            customPinView.pinColor = MKPinAnnotationColorGreen;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            
            //Add a custom Button for the station/stop call out box to show next train times soon.
            UIButton *showTimeTableButton = [UIButton buttonWithType: UIButtonTypeCustom];
			[showTimeTableButton setFrame:CGRectMake(0., 0., 45., 45.)];
			[showTimeTableButton setImage:[UIImage imageNamed: @"timetable"] forState:UIControlStateNormal];
            customPinView.rightCalloutAccessoryView = showTimeTableButton;
            customPinView.rightCalloutAccessoryView.tag = 0;
            
            // Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
			UIButton *removeRegionButton = [UIButton buttonWithType: UIButtonTypeCustom];
			[removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
			[removeRegionButton setImage:[UIImage imageNamed:@"StopIcon"] forState:UIControlStateNormal];
			customPinView.leftCalloutAccessoryView = removeRegionButton;
            customPinView.rightCalloutAccessoryView.tag = 1;

            return customPinView;

        }
        else
        {
            //else return a normal annotation object
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    
    return nil;
}

//Callout buttons tapped
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
      #warning Annotation Buttons need further work to show train times and remove region.
    
    //Check which button got clicked left or right by its tag number set.
      if (control.tag == 0)
      {
          //NSLog(@"Clicked Left Button");
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Switch off the alert!"
                                                            message:@"This is the area to turn off the alert for this alarm while still being able to access all the extra information shown on this VC!"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles:nil];
          //show the alert to user
         [alertView show];
      }
      else if (control.tag == 1)
      {
          // NSLog(@"Clicked Right Button");
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Next 3 Train Times" message:@"This is your first UIAlertview message.\nThis is second line.\nThird Line\n4thLine etc etc" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
          
          //show alert
          [alertView show];
      }
}

//Used to calc the distance between two locations in this case the user location and the station in question.
-(float)kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to
{
    
    CLLocation *userLoc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *stationLoc = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userLoc distanceFromLocation:stationLoc]/1000;
    
    //NSLog(@"Distance between is: %f km's away.", dist);
    
    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
    
}

@end
