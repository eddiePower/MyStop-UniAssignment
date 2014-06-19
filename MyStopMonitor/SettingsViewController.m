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

const double cSLIDERMULTIPLYER = 600.00;


@interface SettingsViewController ()

@property(nonatomic)double radiusUpdate;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.soundsList = [[NSArray alloc] initWithObjects:@"Voice alert", @"Train Horn", @"Alarm Clock", @"Train Crossing", @"Phone sound 1", nil];
    
    
    // Create userDefaults store
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
    double startRadius = tempString.doubleValue;
    
    //center location for mapView
    CLLocationCoordinate2D demoRadiusCenter;
    demoRadiusCenter.latitude = -37.818877;
    demoRadiusCenter.longitude = 144.964488;
    
    MKMapPoint pt = MKMapPointForCoordinate(demoRadiusCenter);
    double w = MKMapPointsPerMeterAtLatitude(demoRadiusCenter.latitude) * (startRadius * 2);
    MKMapRect mapRect = MKMapRectMake(pt.x - w/2.0, pt.y - w/2.0, w, w);
    [self.radiusMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(32, 0, 8, 0) animated: YES];
    
    //set the sliders range so it will be able to represent values from 600m - 1.5km
    self.radiusSlider.minimumValue = 0.6f;
    self.radiusSlider.maximumValue = 1.5f;
    
    //Check the starting radius and set both radius slider location
    //radius label text and an initial circle for the radius view.
    if (startRadius)
    {
        //Take saved radius value and devide by multiplyer as thats reversed when saved (timesed by multiplier)
        self.radiusSlider.value = startRadius / cSLIDERMULTIPLYER;
        self.radiusSizeLabel.text = [NSString stringWithFormat:@"Size: %fm ", (self.radiusSlider.value * cSLIDERMULTIPLYER)];
    }
    else
    {
        [self.radiusMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(32, 0, 8, 0) animated: NO];
       
        //get a value the slider can display beteen min of .6 and max of 1.5
       self.radiusSlider.value = 500 / cSLIDERMULTIPLYER;
        //Format a string to show user the value of radius during resize.
        NSString *formattedLabelText = [self formatRadiusLabel];
       self.radiusSizeLabel.text = [NSString stringWithFormat:@"Size: %@m ",formattedLabelText];
        
        //This value is used only for the first run to create a radius start point
        // when no alarms have been set and is used in the create overlay method.
        [defaults setValue: [NSString stringWithFormat:@"%f", self.radiusSlider.value] forKey:@"alertRadius"];
        //save defaults
        [defaults synchronize];
        
    }
    
    //Set mapView delegate
    self.radiusMapView.delegate = self;
    
     //initalize annotation for radius demo
    MKPointAnnotation *radiusDemoAnnotation = [[MKPointAnnotation alloc]init];
    
    radiusDemoAnnotation.coordinate = demoRadiusCenter;
    radiusDemoAnnotation.title = @"Flinders Street Station";
    radiusDemoAnnotation.subtitle = @"New Alert's radius size visualization";
    
    //Add annotation array to the map
    [self.radiusMapView addAnnotation: radiusDemoAnnotation];
    
    //overridden method below, adds custom pin and callout.
    [self.radiusMapView viewForAnnotation: radiusDemoAnnotation];
    
    //Update new value from user defaults
    tempString = [defaults objectForKey:@"alertRadius"];
    
    //store as a double
    double tempRadius = tempString.doubleValue;
    
    //create map overlay in circle shape and use alert radius from alarm class
    // as circle radius
    self.radiusOverlay = [MKCircle circleWithCenterCoordinate: demoRadiusCenter radius: tempRadius];
    
    //set the overlay
    [self.radiusMapView addOverlay: self.radiusOverlay];
}

//MapView delegate
//Draw region overlay on map
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    //create circle render object with circle
    MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
    //set the outline colour
    circleR.strokeColor = [UIColor blueColor];
    //set fill or center colour
    circleR.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
    //set the width of the outer line.
    circleR.lineWidth = 3;
    
    //return render object for showing the circle overlays
    return circleR;
}


//Set the map type for demo map will also make this set main map using
//user defaults plist
- (IBAction)segmentSelected:(UISegmentedControl *)sender
{
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
    
    //set the value for the setting alertRadius
    [defaults setDouble: tempSlider.value * cSLIDERMULTIPLYER forKey:@"alertRadius"];
    //Save new value to defaults file
    [defaults synchronize];
    
    //resize and re draw the overlay
    [self configureOverlay];
    //remove the old overlay with inaccurate radius value. this is done
    // because the radius value on overlays is read only and can only be edited on creation.
    [self.radiusMapView removeOverlay:[self.radiusMapView.overlays firstObject]];

    //Format a string to show user the value of radius during resize.
    NSString *formattedLabelText = [self formatRadiusLabel];
    self.radiusSizeLabel.text = [NSString stringWithFormat:@"Size: %@m ", formattedLabelText];
    
    
    //center location for demo radius mapView
    CLLocationCoordinate2D demoRadiusCenter;
    demoRadiusCenter.latitude = -37.818877;
    demoRadiusCenter.longitude = 144.964488;
    
    //create a map point to set as the center point for the map
    MKMapPoint pt = MKMapPointForCoordinate(demoRadiusCenter);
    double w = MKMapPointsPerMeterAtLatitude(demoRadiusCenter.latitude) * (formattedLabelText.doubleValue * 2);
    //set the map rectangle or the biggest sqare of map that will encompas the overlay as well.
    MKMapRect mapRect = MKMapRectMake(pt.x - w/2.0, pt.y - w/2.0, w, w);
    //add the mapRect as the visibale map rectangle.
    [self.radiusMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(32, 0, 8, 0) animated: YES];
}

//Format the radius label number into one with 2 decimal places for easier viewing.
-(NSString *)formatRadiusLabel
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Convert the string to double
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
    //Number space for label output.
    NSNumber *radiusNumber = [NSNumber numberWithDouble: tempString.doubleValue];
    //Format the number data type for radius to appear in a clean decimal 0.000 format.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //this rounds the decimal places off to 3.
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    //store a string of the formatted number item_price.
    NSString *radiusFormatted = [formatter stringFromNumber: radiusNumber];
    
    return radiusFormatted;
}

- (void)configureOverlay
{
    // Create userDefaults store
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
    double tempRadius = tempString.doubleValue;
    
    //center location for mapView
    CLLocationCoordinate2D demoRadiusCenter;
    demoRadiusCenter.latitude = -37.818877;
    demoRadiusCenter.longitude = 144.964488;
    
    self.radiusOverlay = [MKCircle circleWithCenterCoordinate: demoRadiusCenter radius: tempRadius];

    [self.radiusMapView addOverlay: self.radiusOverlay];
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

//UIPicker delegate methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return [self.soundsList count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [self.soundsList objectAtIndex: row];
}
//End Picker delegate methods.

@end
