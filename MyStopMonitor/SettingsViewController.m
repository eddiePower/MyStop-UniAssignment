/*////////////////////////////////////////////////////////////////////////////////
//  SettingsViewTableViewController.m                                          //
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

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property(nonatomic)double radiusUpdate;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create userDefaults store
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
    
    double startRadius = tempString.doubleValue;
    
    NSLog(@"Radius to be set on slider is: %f", startRadius / 1000);
    
    self.radiusSlider.minimumValue = 0.6f;
    self.radiusSlider.maximumValue = 1.5f;
    
    self.radiusSlider.value = startRadius / 1000;
    
    //Set mapView delegate
    self.radiusMapView.delegate = self;
    
    //Set the region/area for the mapView location to show. - Flinders Street Station Melbourne Australia.
    MKCoordinateRegion mapRegion;
    
    //center location for mapView
    CLLocationCoordinate2D demoRadiusCenter;
    demoRadiusCenter.latitude = -37.818078;
    demoRadiusCenter.longitude = 144.96681;
    
    //Span @ % of degree = 100th of degree
    MKCoordinateSpan demoRadiusSpan;
    demoRadiusSpan.latitudeDelta = 0.02f;
    demoRadiusSpan.longitudeDelta = 0.02f;
    
    //Set center and span for the mapView region
    mapRegion.center = demoRadiusCenter;
    mapRegion.span = demoRadiusSpan;
    
    //Set the Region to the mapView.
    [self.radiusMapView setRegion: mapRegion animated: YES];
    
    //initalize annotation for radius demo
    MKPointAnnotation *radiusDemoAnnotation = [[MKPointAnnotation alloc]init];
    
    radiusDemoAnnotation.coordinate = demoRadiusCenter;
    radiusDemoAnnotation.title = @"Flinders Street Station";
    radiusDemoAnnotation.subtitle = @"Alert radius size visualization, set for new Alerts only.";
    
    //Add annotation array to the map
    [self.radiusMapView addAnnotation: radiusDemoAnnotation];
    
    //overridden method below, adds custom pin and callout.
    [self.radiusMapView viewForAnnotation: radiusDemoAnnotation];
    
    tempString = [defaults objectForKey:@"alertRadius"];
    
    double tempRadius = tempString.doubleValue;
    
    
    //create map overlay in circle shape and use alert radius from alarm class
    // as circle radius
    MKCircle *circle = [MKCircle circleWithCenterCoordinate: demoRadiusCenter radius: tempRadius];
    
    [self.radiusMapView addOverlay: circle];
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


//Set the map type for demo map will also make this set main map using
//user defaults plist
- (IBAction)segmentSelected:(UISegmentedControl *)sender
{
    //NSLog(@"Segment has changed!!");
    
    switch (self.mapSegment.selectedSegmentIndex)
    {
        case 0:
            self.radiusMapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.radiusMapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.radiusMapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}

- (IBAction)sliderValueChanged:(id)sender
{
    // Create userDefaults store
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    UISlider *tempSlider = sender;

    //NSLog(@"RadiusUpdate val: %.1f meters accross", tempSlider.value * 1000);
    
    [defaults setDouble: tempSlider.value * 1000 forKey:@"alertRadius"];
    
    [defaults synchronize];
    
    [self.radiusMapView removeOverlay:[self.radiusMapView.overlays firstObject]];
    [self configureOverlay];
    
    //NSLog(@"Defaults updated with: %@", [defaults objectForKey:@"alertRadius"]);
}

- (void)configureOverlay
{
    // Create userDefaults store
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
    
    double tempRadius = tempString.doubleValue;
    
    [self.radiusMapView removeOverlays:[self.radiusMapView.overlays firstObject]];
    
    //center location for mapView
    CLLocationCoordinate2D demoRadiusCenter;
    demoRadiusCenter.latitude = -37.818078;
    demoRadiusCenter.longitude = 144.96681;
        
    MKCircle *circle = [MKCircle circleWithCenterCoordinate: demoRadiusCenter radius: tempRadius];
    [self.radiusMapView addOverlay: circle];

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
    if ([annotation isKindOfClass:[annotation class]])
    {
        static NSString *StopAnnotationIdentifier = @"demoRadiusAnnotation";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *)[self.radiusMapView dequeueReusableAnnotationViewWithIdentifier: StopAnnotationIdentifier];
        if (pinView == nil)
        {
            //if an existing pin view was not available, create one
            MKPinAnnotationView *customPinView =
            [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: StopAnnotationIdentifier];
            
            //Customize the pin view.
            customPinView.canShowCallout = YES;
            
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

@end
