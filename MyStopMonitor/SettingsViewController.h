//  SettingsViewTableViewController.h                                       
//  MyStopMonitor

//  This class creates a tableView controller that shows a static table
//  of UIControlls to help the user customise the look and operation of the
//  application, it holds controlls such as a UISlider for alarm radius setting
//  a UISegmentControl to set the mapView Type, and a UIPickerView that will soon
//  allow users to pick a specific sound for the alerts both in app and notification sounds.
//  This class is a subclass of the UITableViewController and employs a MKMapDelegate and UIPickerDataSource
//  and pickerViewDelegate methods to recieve feedback and place data into both picker view and mapview.
 
//  Created by Eddie Power on 7/05/2014.
//  Copyright (c) 2014 Eddie Power.
//  All rights reserved.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SettingsViewController : UITableViewController<MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSegment;
@property (weak, nonatomic) IBOutlet MKMapView *radiusMapView;
@property (strong, nonatomic) MKCircle *radiusOverlay;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *radiusSizeLabel;
@property (nonatomic, readonly) MKMapRect boundingMapRect;
@property (nonatomic) CLLocationCoordinate2D mapCoordinate;

@property (weak, nonatomic) IBOutlet UIPickerView *soundPicker;
@property(strong, nonatomic) NSArray *soundsList;


- (IBAction)segmentSelected:(UISegmentedControl *)sender;
- (IBAction)sliderValueChanged:(id)sender;

@end
