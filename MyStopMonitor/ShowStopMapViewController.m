/*////////////////////////////////////////////////////////////////////////////////
//  ShowStopMapViewController.h                                                //
//  MyStopMonitor                                                             //
//                                                                           //
//  This project is to use the ios core location to monitor a users         //
//  location while on public transport in this case a train running        //
//  on the Frankston Line and a user will set the stop they would         //
//  like to be notified before they reach, the phone will then           //
//  alert the user to the upcoming stop and they can wake up or         //
//  prepare to disembark the train with lots of time and not           //////////
//  missing there stop. This will be widened to accept multiple               //
//  train lines and transport types in an upcoming update soon.              //
//                                                                          //
//  The above copyright notice and this permission notice shall            //
//  be included in all copies or substantial portions of the              //
//  Software.                                                            //
//                                                                      //
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY          //
//  KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE        //
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR          //
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE              //
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,          //
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF           //
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN       //
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER            //
//  DEALINGS IN THE SOFTWARE.                                  //
//                                                            //
//  Created by Eddie Power on 7/05/2014.                     //
//  Copyright (c) 2014 Eddie Power.                         //
//  All rights reserved.                                   //
////////////////////////////////////////////////////////////*/


#import "ShowStopMapViewController.h"
#import "StopAnnotation.h"

@implementation ShowStopMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mapBg"]]];
    
    // Create userDefaults store
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //MapView Configuration.
    self.mapView.showsBuildings = YES;
    self.mapView.showsUserLocation = YES;
    
    self.stationNameLabel.text = self.mapStation.stationName;
    self.stationTypeLabel.text = [NSString stringWithFormat:@"Transport Type: %@", self.mapStation.stationStopType];
   
    //Set the mapView Delegate to return to itself for annotations.
    self.mapView.delegate = self;
   
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
    
    double tempRadius = tempString.doubleValue;
    
    //center location for mapView
    CLLocationCoordinate2D center;
    center.latitude = [self.mapStation.stationLatitude doubleValue];
    center.longitude = [self.mapStation.stationLongitude doubleValue];
    
    MKMapPoint pt = MKMapPointForCoordinate(center);
    double w = MKMapPointsPerMeterAtLatitude(center.latitude) * (tempRadius * 2);
    MKMapRect mapRect = MKMapRectMake(pt.x - w/2.0, pt.y - w/2.0, w, w);
    [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(30, 0, 25, 0) animated: NO];
    
    

    

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
    MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
    circleR.strokeColor = [UIColor blueColor];
    circleR.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
    circleR.lineWidth = 3;
    
    return circleR;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }

    // handle my custom annotation may add others for bus/train/tram or other use.
    // for station or stop annotation
    if ([annotation isKindOfClass:[StopAnnotation class]])
    {
        
        static NSString *StopAnnotationIdentifier = @"StopAnnotation";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier: StopAnnotationIdentifier];
        if (pinView == nil)
        {
            //if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView =
            [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: StopAnnotationIdentifier];
            
            //Customize the pin view.
            customPinView.pinColor = MKPinAnnotationColorGreen;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            #warning Annotation Buttons need further work to show train times and remove region.
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
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    
    return nil;
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
      if (control.tag == 0)
      {
          //NSLog(@"Clicked Left Button");
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Switch off the alert!"
                                                            message:@"This is the area to turn off the alert for this alarm while still being able to access all the extra information shown on this VC!"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles:nil];
          
         [alertView show];

      }
      else if (control.tag == 1)
      {
          // NSLog(@"Clicked Right Button");
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Next 3 Train Times" message:@"This is your first UIAlertview message.\nThis is second line.\nThird Line\n4thLine etc etc" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
          
          [alertView show];

      }
    
}


@end
