/*  AlarmListController.h
//  MyStopMonitor

//  This class is used to create a TableViewController
//  that is used to display a list of alarms that the user
//  has set.  It also makes use of alocation manager set up
//  in the application delegate and passed to this class to track
//  the users current location and region entry to trigger a user alert
//  which is a method in this class that at this time makes the phone speak if
//  the application is in the forground and play a train crossing sound effect if
//  the application is closed or running in the background.  The user alert
//  also includes a UIAlertView, a localNotification from a custom class, and
//  an in app animation from another custom class that diplays a green banner
//  when the alert is triggered in the app.  These custom classes are refrenced in
//  the readme file.
 
//  Created by Eddie Power on 7/05/2014.
//  Copyright (c) 2014 Eddie Power.
//  All rights reserved.
*/
 
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@import AVFoundation;  //new import type used for voice synth
@import CoreLocation;
#import "AlarmCell.h"
#import "AddStopController.h"
#import "ShowStopMapViewController.h"

@interface AlarmListController : UITableViewController <AddAlarmStopDelegate, CLLocationManagerDelegate>
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//location manager
@property(strong, nonatomic) CLLocationManager *locManager;
//user alert voice
@property(strong, nonatomic) AVSpeechSynthesizer *alertSynthesizer;
@property(strong, nonatomic) Alarm *anAlarmToStore;
@property(strong, nonatomic) NSMutableArray* currentAlarms;
@property(strong, nonatomic) NSString *stopDistanceStore;

//methods to addAlarmRegion and remove a region.
-(void)addAlarmRegion:(Alarm *)anAlarm;
-(void)removeStopRegion:(Alarm *)anAlarm;


@end
