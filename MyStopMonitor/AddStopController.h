//  AddStopController.h
//  MyStopMonitor

//  This class is used to create a UITableViewController object
//  and set the delegate methods for the table view data source,
//   searchBar methods, keyboard delegate methods. I set up the search
//  bar in this view controller to help users search for the stop
//  they wish to add to the alarm they are setting up. The main function
//  of this class is to display a list of stations for a user to choose from
//  to add to an alarm. This is a subclass of the UITableViewController.
 
//  Created by Eddie Power on 7/05/2014.
//  Copyright (c) 2014 Eddie Power.
//  All rights reserved.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@import CoreLocation;
#import <CoreData/CoreData.h>
#import "Alarm.h"
#import "StationCell.h"
#import "TrainLine.h"
#import "GenerateSigniture.h"

//AddAlarmStation delegate protocol,
@protocol AddAlarmStopDelegate <NSObject>

//method to add a station to the alarm object.
-(void)addAlarmStop:(Alarm *)anAlarm;

@end

@interface AddStopController : UITableViewController <UISearchBarDelegate>

@property(strong, nonatomic) NSArray *stationsArray;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(weak, nonatomic) id<AddAlarmStopDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

//Will update application to work with multiple train lines and eventually bus and tram lines.
@property (strong, nonatomic) TrainLine* trainLine;

@end
