/*////////////////////////////////////////////////////////////////////////////////
//  StopMonitorAppDelegate.m                                                   //
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

#import "StopMonitorAppDelegate.h"
#import "ACPReminder.h"

@implementation StopMonitorAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Customeize View of all pages of the app for specific UIKit controlls
    [self styleMyApplication];
    
    //Create my Core Data Stack!
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
    
    NSURL *storeUrl = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"StationAlarms.sqlite"];

    //Error memory space for error checking
    NSError *error;
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
    
    //Create location manager for use through out the application
    self.locationManager = [[CLLocationManager alloc] init];
    //Start updating the location data of the user to begin monitoring regions.
    [self.locationManager startUpdatingLocation];
        
    //Set desired accuracy as high as feasable due to purpose of the app.
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    //self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    //set the location manager used on other pages so monitoring dosnt stop at wrong time.
    alarmListController.locManager = self.locationManager;
    self.locationManager.delegate = alarmListController;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
        //run like normal
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever so set users view to the welcome page.
        
        StopMonitorInfoViewController *infoViewController = [[StopMonitorInfoViewController alloc] init];
        infoViewController = [tabController.viewControllers lastObject];

        //IF its first time user has run app open up on instruction page to help UI questions
        if (infoViewController.tabBarItem.tag == 1)
        {
            infoViewController.tabBarItem.badgeValue = @"Help";
        }
        
        //[alarmListController presentViewController: infoViewController animated: NO completion:nil];

    }

    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /* Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.*/
    
    // In case user goes to home screen after interupt, Reset the icon badge number to zero.
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //Check background GPS monitoring is available
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
		// Stop normal location updates and start significant location change updates for battery efficiency.
		[self.locationManager stopUpdatingLocation];
		[self.locationManager startMonitoringSignificantLocationChanges];
        
         NSLog(@"About to switch to background monitoring, possibly due to incoming interuption(call, sms, other alert).");
	}
	else
    {
		NSLog(@"Significant location change monitoring is not available. Interup request is interupting!");
	}
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
	// Reset the icon badge number to zero.
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    //Current Regions check & copy to workable array
    ///Note: may use this for clean up on exit and then rebuild on restart,
    //        build into core data for save state.
    
    //NSMutableArray *regions = [[NSMutableArray alloc] init];
    //regions = [[self.alarmListController.locManager monitoredRegions] allObjects].mutableCopy;
    
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

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //Check if the ACP reminder has been triggered to reset timer for next notification
    //which ive set as X seconds after an event happens or user alert method is triggered.
    [[ACPReminder sharedManager] checkIfLocalNotificationHasBeenTriggered];

	if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
		// Stop significant location updates and start normal location updates again since the app is in the forefront.
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)styleMyApplication
{
    // Customizing the UISlider appearence in this view.
    UIImage *minImage = [[UIImage imageNamed:@"slider_minimum.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_maximum.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *thumbImage = [UIImage imageNamed:@"thumb.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateNormal];
    
    // Customing the segmented control
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
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected
                                               forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected
                                               forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
                                 forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance]
     setDividerImage:segUnselectedSelected
     forLeftSegmentState:UIControlStateNormal
     rightSegmentState:UIControlStateSelected
     barMetrics:UIBarMetricsDefault];
}

@end
