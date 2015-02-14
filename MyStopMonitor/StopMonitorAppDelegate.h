//  StopMonitorAppDelegate.h
//  MyStopMonitor
//
//  This project is to use the ios core location to monitor a users
//  location while on public transport in this case a train running
//  on the Frankston Line and a user will set the stop they would
//  like to be notified before they reach, the phone will then
//  alert the user to the upcoming stop and they can wake up or
//  prepare to disembark the train with lots of time and not
//  missing there stop. This will be widened to accept multiple
//  train lines and transport types in an upcoming update soon.
 
 //  Created by Eddie Power on 7/05/2014.
 //  Copyright (c) 2014 Eddie Power.
 //  All rights reserved.

#import <UIKit/UIKit.h>
@import CoreData;
@import CoreLocation;
#import "AlarmListController.h"
#import "StopMonitorInfoViewController.h"

@interface StopMonitorAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//view to open to when app loads & locManager
@property (strong, nonatomic) AlarmListController *viewController;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
