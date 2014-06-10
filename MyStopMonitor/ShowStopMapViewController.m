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
    //MapView Configuration.
    self.mapView.showsBuildings = YES;
    self.mapView.showsUserLocation = YES;
    
    self.stationNameLabel.text = self.mapStation.stationName;
    self.stationTypeLabel.text = [NSString stringWithFormat:@"Transport Type: %@", self.mapStation.stationStopType];
   
    //Set the mapView Delegate to return to itself for annotations.
    self.mapView.delegate = self;
   
    //Set the region/area for the mapView location to show.
    MKCoordinateRegion mapCoordRegion;
    
    //center location for mapView
    CLLocationCoordinate2D center;
    center.latitude = [self.mapStation.stationLatitude doubleValue];
    center.longitude = [self.mapStation.stationLongitude doubleValue];
    
    //Span @ % of degree = 100th of degree
    MKCoordinateSpan span;
    span.latitudeDelta = 0.001f;
    span.longitudeDelta = 0.001f;
    
    //Set center and span for the mapView region
    mapCoordRegion.center = center;
    mapCoordRegion.span = span;
    
    //Set the Region to the mapView.
    [self.mapView setRegion: mapCoordRegion animated: YES];

    //initalize annotation for Stop with title, coord's
    //  and subtitle used for display only - user visulisation of station.
    StopAnnotation *item = [[StopAnnotation alloc] initWithTitle:self.mapStation.stationName aCoord:center andSubtitle:self.mapStation.stationStopType];

    //Add annotation array to the map
    [self.mapView addAnnotation: item];
   
    //overridden method below, adds custom pin and callout.
    [self.mapView viewForAnnotation: item];
    
    //FUTURE ADD TO MARKER THE MYKI OUTLET STATUS AND PARKING STATUS OF STATIONS.
    //Maybe in the call outs or with seperate annotations
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
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            //Add a custom Button for the station/stop call out box to show next train times soon.
            UIButton *showTimeTableButton = [UIButton buttonWithType: UIButtonTypeCustom];
			[showTimeTableButton setFrame:CGRectMake(0., 0., 45., 45.)];
			[showTimeTableButton setImage:[UIImage imageNamed: @"StopIcon"] forState:UIControlStateNormal];
            customPinView.rightCalloutAccessoryView = showTimeTableButton;
            
            // Create a button for the left callout accessory view of each annotation to remove the annotation and region being monitored.
			UIButton *removeRegionButton = [UIButton buttonWithType: UIButtonTypeCustom];
			[removeRegionButton setFrame:CGRectMake(0., 0., 25., 25.)];
			[removeRegionButton setImage:[UIImage imageNamed:@"RemoveRegion"] forState:UIControlStateNormal];
			customPinView.leftCalloutAccessoryView = removeRegionButton;
            
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
