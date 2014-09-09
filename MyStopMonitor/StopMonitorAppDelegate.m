//  StopMonitorAppDelegate.m                                       
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

#import "StopMonitorAppDelegate.h"
#import "ACPReminder.h"

@implementation StopMonitorAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Customeize View of all pages of the app for specific UIKit controlls
    //[self styleMyApplication];
    
    //Create my Core Data Stack!
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
    
    //Set store url which includes urlPath, documents folder location, and fileName all inline.
    NSURL *storeUrl = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"StationAlarms.sqlite"];

    //Error memory space for error checking
    NSError *error;
    //check and save persistant store to filesystem.
    if (![self.persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
    {
        NSLog(@"Could not create / load the persistent Store:\n%@", error.userInfo);
    }
    
    //create managed object context memory space.
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    //Set up the first view controller location.
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navController = [tabController.viewControllers firstObject];    
    //Set the AlarmListController which uses the Core Data stack.
    AlarmListController *alarmListController = [navController.viewControllers firstObject];
    alarmListController.managedObjectContext = self.managedObjectContext;
    
    //Create location manager for use globally through-out the application
    self.locationManager = [[CLLocationManager alloc] init];
    //Start updating the location data of the user to begin monitoring regions after app loads.
    [self.locationManager startUpdatingLocation];
        
    //Set desired accuracy as high as feasable due to purpose of the app.
    //may set a switch in settings to lower the accuracy to save battery life.
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    //self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    //set the location manager used on other pages so monitoring dosnt stop at wrong time.
    alarmListController.locManager = self.locationManager;
    //set the delegate for the alarmListController.
    self.locationManager.delegate = alarmListController;
    
    //check if the userDefaults file has a bool value for hasLaunchedOnce
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched before so dont change anything
        //run like normal
    }
    else
    {
        //app is running for the very first time
        //set the value of HasLaunchedOnce to YES or True
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"HasLaunchedOnce"];
        //save user defaults
        [[NSUserDefaults standardUserDefaults] synchronize];

        //set location of the tabBar item or viewController that is the info page.
        StopMonitorInfoViewController *infoViewController = [[StopMonitorInfoViewController alloc] init];
        infoViewController = [tabController.viewControllers lastObject];

        //IF its first time user has run app open up on instruction page to help UI questions
        if (infoViewController.tabBarItem.tag == 1)
        {
            //set a red badge on the tabBar item that shows the word Help
            // this will help the first time users work out how the app functions.
            infoViewController.tabBarItem.badgeValue = @"Help";
        }
        
        //[alarmListController presentViewController: infoViewController animated: NO completion:nil];

    }

    return YES;
}

//This is fired when the app is about to resign or go into background state.
- (void)applicationWillResignActive:(UIApplication *)application
{
    // If user goes to home screen Reset the icon badge for alerts number to zero.
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //Check background GPS monitoring is available
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
		// Stop normal location updates and start significant location change updates for battery efficiency.
		[self.locationManager stopUpdatingLocation];
		[self.locationManager startMonitoringSignificantLocationChanges];
        
        //set a debug log to show switch is taking place
         NSLog(@"About to switch to background monitoring, possibly due to incoming interuption(call, sms, other alert).");
	}
	else
    {
        //error output for tracking any issues.
		NSLog(@"Significant location change monitoring is not available. Interup request is interupting!");
	}
}

//application is now running but in the background
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
	// Reset the icon badge number to zero.
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    //Check background GPS monitoring is available
	if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
		// Stop normal location updates and start significant location change updates for battery efficiency.
		[self.locationManager stopUpdatingLocation];
		[self.locationManager startMonitoringSignificantLocationChanges];
        
        NSLog(@"Switching to monitor Background location Changes.");
	}
	else
    {
		NSLog(@"Significant location change monitoring is not available.");
	}
}

//called before the app re enters the forground can be used to reset any values
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//app has returned to front or is now active
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //Part of the custom Class ACPReminder stored in ExtraResource folder and was sourced from
    //gitHub as refrenced in readMe file.
    
    //Check if the ACP reminder has been triggered to reset timer for next notification
    //which ive set as X seconds after an event happens or user alert method is triggered.
    [[ACPReminder sharedManager] checkIfLocalNotificationHasBeenTriggered];

    //if signifigantlocation change monitoring is available
	if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
		// Stop significant location updates and start normal location
        // updates again since the app is in the forefront.
		[self.viewController.locManager stopMonitoringSignificantLocationChanges];
		[self.viewController.locManager startUpdatingLocation];
        //NSLog(@"Stopping monitoring Background signifigant Changes now.");
	}
	else
    {
		NSLog(@"Significant location change monitoring is not available.");
	}

    // Reset the icon badge number to zero.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

//called before the app terminates or quits this is where preperation like saving
// app state can happen.
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//this is called to style some elements of tha app with a custom
// look not normally what i would take on myself but it shows i can do it.
-(void)styleMyApplication
{
    // Customizing the UISlider appearence in this view.
    UIImage *minImage = [[UIImage imageNamed:@"slider_minimum.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_maximum.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *thumbImage = [UIImage imageNamed:@"thumb.png"];
    
    //set images to colour the max and min tracks and a new thumb or slider controle part.
    [[UISlider appearance] setMaximumTrackImage:maxImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateNormal];
    
    // Customing the segmented control look with image and widths both selected and unselected
    UIImage *segmentSelected =
    [[UIImage imageNamed:@"segcontrol_sel.png"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    UIImage *segmentUnselected =
    [[UIImage imageNamed:@"segcontrol_uns.png"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    UIImage *segmentSelectedUnselected =
    [UIImage imageNamed:@"segcontrol_sel-uns.png"];
    UIImage *segUnselectedSelected =
    [UIImage imageNamed:@"segcontrol_uns-sel.png"];
    UIImage *segmentUnselectedUnselected =
    [UIImage imageNamed:@"segcontrol_uns-uns.png"];
    
    //set background of segments
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected
                                               forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected
                                               forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    //set divider images both selected and not.
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
                                 forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
   
    //set the appearance with settings for segmentControlls.
    [[UISegmentedControl appearance]
     setDividerImage:segUnselectedSelected
     forLeftSegmentState:UIControlStateNormal
     rightSegmentState:UIControlStateSelected
     barMetrics:UIBarMetricsDefault];
}

@end
