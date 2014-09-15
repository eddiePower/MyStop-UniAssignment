/*  AlarmListController.m
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

#import "AlarmListController.h"
#import "ACPReminder/ACPReminder.h"
#import "TDNotificationPanel.h"

@implementation AlarmListController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create userDefaults store and check for alertRadius value in it.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //set up an initial value for the alertRadius so its not 0 on a new install.
    //users can then change this value with the slider on settings page.
    [defaults setValue: @"0.8" forKeyPath: @"alertRadius"];
    [defaults synchronize];
    
    //NSLog(@"Default object radius is now set at: %@", [defaults valueForKeyPath:@"alertRadius"]);
    
    //Allow the edit for re ordering and deletion of many cells
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Initalize alertSynth object for user alert to region entry.
    self.alertSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    //set location manager delegate to return to this view.
    self.locManager.delegate = self;
    
    //set fetch request to get the Alarm entities
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Alarm"];
    
    NSError *error;
    //execute or retrieve alarm objects
    NSArray *results = [self.managedObjectContext executeFetchRequest: fetchRequest error: &error];
    
    //check there are results
    if(results == nil)
    {
        NSLog(@"Could Not fetch Alarm:\n%@", error.userInfo);
    }
    else if ([results count] == 0)
    {
        //if there are no results then just create an empty array for the alarmView to use later.
        self.currentAlarms = [[NSMutableArray alloc] initWithCapacity: 0];
    }
    else
    {
        //Use mutableCopy of Array results as current alarms is a mutable array.
        self.currentAlarms = [results mutableCopy];
        
        //Alarm *tempAlarm = [[Alarm alloc] init];
//        for (Alarm* anAlarm in self.currentAlarms)
//        {
//            NSLog(@"Alarm Stop name: %@", anAlarm.station.stationName);
//        }
    }
}


//May be used later to prep regions or data to use.
- (void)viewDidAppear:(BOOL)animated
{
    //quickly get current location of user to compare to location of each alarm
    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    [locManager startUpdatingLocation];
    
    //update distance to location of alarms on each reload of page.
    //Alarm *tempAlarm = [[Alarm alloc] init];
    for (Alarm* anAlarm in self.currentAlarms)
    {
        //NSLog(@"Alarm Stop name: %@", anAlarm.station.stationName);
        
        //set up a station 2D coord.
        CLLocationCoordinate2D center;
        center.latitude = anAlarm.station.stationLatitude.doubleValue;
        center.longitude = anAlarm.station.stationLongitude.doubleValue;
        
        //fill out the distance between user local and station.
        anAlarm.alarmDistance = [NSString stringWithFormat: @"%.2f km's away", [self kilometersfromPlace: locManager.location.coordinate andToPlace: center]];
    }
    
    [locManager stopUpdatingLocation];
    
    
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


//number of sections to return as i am counting alarms set this is 2
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //One for alarms and other for count of alarms.
    // This may change to save screen realestate.
    return 2;
}

//number of rows is the number of alarms in the array or 1 row for the alarm count section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            //count rows in section
            return [self.currentAlarms count];
            break;
        case 1:
            //or its just 1 row for total
            return 1;
    }
    return 0;
}

//Conficure the data for the cell prototype AlarmCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if the user selected the first section or not the alarm total section
    if (indexPath.section == 0)
    {
        //set unchangable string for cell identifier
       static NSString *CellIdentifier = @"AlarmCell";
        //deque or check for a cell with the identifier which i set in storyboard.
       AlarmCell *cell = (AlarmCell*)[tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                                    forIndexPath: indexPath];

       // Configure the Alarm cell with alarm details.
       Alarm* a = [self.currentAlarms objectAtIndex: indexPath.row];
    
        //use alarm details to populate some labels.
        cell.alarmSuburbLabel.text = a.station.stationSuburb;
        cell.alarmStopNameLabel.text = a.station.stationName;
        
        //Calculate the distance from user to station
        //set up and grab the user location from locManager.
        CLLocationManager *locManager = [[CLLocationManager alloc] init];
        [locManager startUpdatingLocation];
        
        //set up a station 2D coord.
        CLLocationCoordinate2D center;
        center.latitude = a.station.stationLatitude.doubleValue;
        center.longitude = a.station.stationLongitude.doubleValue;
        
        //fill out the distance between user local and station.
        cell.alarmDistance.text = a.alarmDistance;
        
        //stop updating user location for now.
        [locManager stopUpdatingLocation];
        
        
        //Add a switch to the alarm Cell.
        UISwitch *alarmActiveSwitch = [[UISwitch alloc] initWithFrame: CGRectZero];

        //use accessoryView to help position the seitch easily.
        cell.accessoryView = alarmActiveSwitch;
        cell.alarmSwitch = alarmActiveSwitch;
        cell.cellAlarm = a;
        
        //run setupCell method in alarmCell class
        [cell setupCell];
        
        //Check initial load state of alarm switch has it been saved in on or off position.
        //and redo that switch
        if (a.alarmIsActive.intValue ==  1)
        {
            //if core data was stored as alarmIsActive then set switch to on at app start up.
            [alarmActiveSwitch setOn: YES animated: YES];
     
            //Add region via alarm object if switch is in on position on application start up.
            [self addAlarmRegion: a];

        }
        else
        {
            //if CD was stored as alarmIsActive then set switch to off position on app start up.
            [alarmActiveSwitch setOn: NO animated: YES];
          
            //Remover region alert by using current alarm details such as station detail.
            [self removeStopRegion: a];
        }
        
       return cell;
    }
    else
    {
        //Total Alarms count cell setup.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TotalCell"
                                                                forIndexPath: indexPath];
        
        cell.textLabel.text = [NSString stringWithFormat:@"Total Alarms Set: %lu/20", (unsigned long)[self.currentAlarms count]];
        
        return cell;
    }
    
    return nil;
}

//Table View method to stop editing / deleting of a specific row in this case the alarm count.
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If the section is the first one or section 0 then allow editing
    if(indexPath.section == 0)
        return YES;
    
    //Otherwise its the alarm count section and no editing permitted.
    return NO;
}

//Save or delete a row/Alarm/Region and update table view data and display.
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If they type of edit initiated by the user is the delete action then
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Create a temp alarm object to store alarm to remove in
        Alarm *alarmToRemove = [self.currentAlarms objectAtIndex: indexPath.row];
        
        //Remove region associated with alarm station object.
        [self removeStopRegion:alarmToRemove];
        
        //remove the alarm object fro m the currentAlarms
        [self.currentAlarms removeObject: alarmToRemove];
        
        //Update the alarms array with the mutableCopy of
        self.currentAlarms = [self.currentAlarms mutableCopy];
        
        //remove the same alarmObject from the managedObjectContext space
        // so that the core data will reflect the Table View Alarm list.
        [self.managedObjectContext deleteObject: alarmToRemove];
        
        //Set the animation of the delete action
        //Comment out to switch to reload all table data
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationFade];
        
        //set animation of the reloaded rows moving up in place of removed row.
        //combines delete and reload tableView data in one.
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: 0 inSection: 1]] withRowAnimation:UITableViewRowAnimationNone];

        //Error checking on the managedObjectContext save method.
        NSError *error;
        if (![self.managedObjectContext save: &error])
        {
            NSLog(@"Could not delete Alarm:\n%@", error.userInfo);
        }
    }
}

//Remove Region monitoring from an Alarm object for region location to remove
-(void)removeStopRegion:(Alarm *)anAlarm
{
    //location coord object and set lat and long to this obj.
    CLLocationCoordinate2D stopCenter;
    stopCenter.latitude = [anAlarm.station.stationLatitude doubleValue];
    stopCenter.longitude = [anAlarm.station.stationLongitude doubleValue];
    
    //geographic circular region to be removed values taken from stored alarm.
    // the value needed to be unique and matching a set region is the identifier
    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                   initWithCenter: stopCenter
                                   radius: [anAlarm.alarmAlertRadius doubleValue]
                                   identifier: anAlarm.station.stationName];
    
        
    //Remove event or region monitoring entry so that the phone will not alert at this region boundry
    [self.locManager stopMonitoringForRegion: geoRegion];
}

//segue method to set segue details
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //check segue name or identifier if it is addAlarmSegue
    if ([segue.identifier isEqualToString:@"AddAlarmSegue"])
    {
        //then set segue destination viewController as AddAlarmStopController
        AddStopController* controller = segue.destinationViewController;
        //pass managed object context from this class to the destination
        // to allow all core data to accessed from the next view.
        controller.managedObjectContext = self.managedObjectContext;
        //set the delegate to the addStopController view.
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"showMapSegue"])
    {
        //set the showMapViewController as the segue destination
        ShowStopMapViewController* controller = segue.destinationViewController;
        
        //return data from mapView controller.
        //NOTE: may use this later to return data from mapView,
        //controller.mapView.delegate = self;
        
        //select the index path sent over by sender or cell selected
        NSIndexPath* indexPath = [self.tableView indexPathForCell: sender];
        
        //create the alarm for the data sent from the indexPath and row for exact data
        Alarm* selectedAlarm = [self.currentAlarms objectAtIndex:indexPath.row];

        //now send [selectedAlarm's Station] to the destination
        //view and a variable called mapStation in destination view
        controller.mapStation = selectedAlarm.station;
    }
}

//Add the station item to the new alarm object,
//add the station location as a region for monitoring.
-(void)addAlarmStop:(Alarm *)anAlarm
{
    // Get the globaly stored settings data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //link to switch value to set alarm inactive/off for user to activate later
    anAlarm.alarmIsActive = [NSNumber numberWithInt: 1];
    
    //set the alarmAlertRadius value to the one stored in the user default
    // store. This is a global settings area for the application.
    
    //set string from defaults store to allow for formating to coreData type.
    NSString *tempRadius = [defaults objectForKey:@"alertRadius"];
    
    if (![tempRadius isEqual:@"0.8"])
    {
        //convert the inital radius number from a string to a NSNumber with double value.
        anAlarm.alarmAlertRadius = [NSNumber numberWithDouble: tempRadius.doubleValue];
        //NSLog(@"\n\n yay theres a val in radius on first load\n%@", tempRadius);
    }
    else
    {
        //if there is no number stored in the defaults file then make up one
        // which users can edit gloabally later for all alarms = one radius.
        anAlarm.alarmAlertRadius = [NSNumber numberWithDouble: 0.8];
    }
    
    

    //date of creation may be used after future update to set repeating alarms.
    //Not really used at this time, may need it later
    anAlarm.alarmTime = [NSDate date];
    
    //set the alarmTitle to the station name,
    //this is set and used to update the CD entries for
    // setting alerts to active via the switch and alarmIsActive property.
    anAlarm.alarmTitle = anAlarm.station.stationName;
    
    //set the location manager to add stop delegate page (addStopController).
    self.locManager.delegate = self;
    
    //Add the region from the alarm to the locManager Monitor Region via custom method.
    [self addAlarmRegion: anAlarm];

    //Add alarm to the array for viewing in the Table View.
    [self.currentAlarms addObject: anAlarm];
    //Reload TableView Data to show new alarm.
    [self.tableView reloadData];
   
    //Set error space to debug any errors
    NSError *error;
    
    //if an error occured when trying to save to managedObject then show userInfo formated output.
    if(![self.managedObjectContext save: &error])
    {
        NSLog(@"Could not add Station to the alarm:\n%@", error.userInfo);
    }
}

//add region to monitor using the alarm details.
- (void)addAlarmRegion:(Alarm *)anAlarm
{
    // Get the globally stored settings data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //set string to retrieve stored value.
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
    //place value in double variable since i know its a double value.
    double tempRadius = tempString.doubleValue;
   
    //Is region monitoring available for this app?
	if ([CLLocationManager isMonitoringAvailableForClass:[CLRegion class]])
    {
        //Begin monitoring the station region just created in the anAlarm object.
        //Used in region init and overlay position.
        CLLocationCoordinate2D stopCenter;
        stopCenter.latitude = [anAlarm.station.stationLatitude doubleValue];
        stopCenter.longitude = [anAlarm.station.stationLongitude doubleValue];
        
		// Start location manager monitoring the alarm stop region, radius & ID.
		[self.locManager startMonitoringForRegion: [[CLCircularRegion alloc]
                                                    initWithCenter: stopCenter
                                                    radius: tempRadius
                                                    identifier: anAlarm.station.stationName]];
	}
	else
    {
		NSLog(@"Region monitoring is not available.");
	}
}

//CLLocationManagerDelegate methods
//Check monitoring for region has started successfully - only needed for development / debugging
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //NSLog(@"\nNow monitoring region named: %@", region.identifier);
}

//Check monitoring for region has stopped successfully - only needed for development / debugging
-(void)locationManager:(CLLocationManager *)manager didStopMonitoringForRegion:(CLRegion *)region
{
    //NSLog(@"\nStoping monitoring region name: %@", region.identifier);
}

//if the region monitoring failed then run this delegate method.
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    //store the error event that just fired in a string with the region details and error detials
	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
    
    //show the error in the log.
    NSLog(@"Event was: %@\n\nError details: %@", event, error.userInfo);
}

//Error checking on region monitoring and iPhone sim error with locations/No GPS
//used in development and debugging usage errors
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //if the error has no user info then it has had a serious error
    if (error.userInfo == nil)
    {
        NSLog(@"Location Manager had a error\nDetails: %@", error.userInfo);
    }
    else
    {
        //otherwise it may be a simulator related error
        NSLog(@"Location Manager had a error\nDetails: Error may have been caused by iPhone Simulator not having GPS chip?!");
    }
}

//May not be needed at this time.
//used to check the location has changed, could be used to save battery life by disabling the
// location manager when movement stops, and starts again when movement does.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{

}

//This method will be the one to alert users to station arival!
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	//Debug lines to show the event that fired which is the user has entered the regionName on xx/xx/xxxx +00:00
    NSString *event = [NSString stringWithFormat:@"You've Entered the Region %@ at %@", region.identifier, [NSDate date]];
    NSLog(@"\nEvent was: %@", event);
    
    //--------Alert the user To Region or station arrival with Sound Alert and Vibrate------------
    //Create string to speak with region name or identifier in it.
    [self alertUserToRegion: region];

}

//not needed in this application.
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	//NSString *event = [NSString stringWithFormat:@"You Exited the Region %@ at %@", region.identifier, [NSDate date]];
    //NSLog(@"Event was: %@", event);
}
//End CLLocationManager delegate methods.

//Check the location of the tableView
//used when an alert is triggered to bring view
//back to top where the alert banner is positioned.
-(void)checkViewLocation
{
    // If active alert banner area is hidden from view, scroll ito top
    //first and if at x:0, y:-80 then dont scroll up anymore
    if (self.tableView.contentOffset.y != -80)
    {
        //scroll tableview to the top if its positioned down, used for the APCReminder class
        //which i found on GitHub as mentioned in readMe file.
        [self.tableView setContentOffset:CGPointMake(0, -80) animated:YES];
    }
}

//Used to calc the distance between two locations in this case the user location and the station in question.
-(float)kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to
{
    
    CLLocation *userLoc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *stationLoc = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userLoc distanceFromLocation:stationLoc]/1000;
    
    //NSLog(@"Distance between is: %f km's away.", dist);
    
    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
    
}

//show the user alert dialogues and sounds
//uses classes found on gitHub refrenced in readMe
-(void)alertUserToRegion:(CLRegion *)region
{
    //--------Alert the user To Region or station arrival with Sound Alert and Vibrate------------
    //Create string to speak with region name or identifier in it.
    NSString *utteranceString = [NSString stringWithFormat: NSLocalizedString(@"Wake up now your almost at %@", nil), region.identifier];
    
    //Create speech or utterance object
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString: utteranceString];
    //set Voice speed.
    utterance.rate = .2f;
    
    //Create user alert box for station arrival alert
    UIAlertView *userAlert;
    
    //create the alert box testing out Localized strings for multiple language support for tourists in melbourne
    userAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Stop Monitor Alarm", nil) message:[NSString stringWithFormat:NSLocalizedString(@"%@ is coming up!", nil), region.identifier] delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel Alert", nil) otherButtonTitles: NSLocalizedString(@"OK im awake!", nil), nil];
    
    //In app animation for arrival at station appears at top of view for 10 seconds, refrenced in ReadMe.txt file.
    //Part of TDNotificationPanel in ExtraRefrences folder and referenced in readMe file.
    [TDNotificationPanel showNotificationInView: self.view
                                          title: NSLocalizedString(@"Next Stop: ", nil)
                                       subtitle: [NSString stringWithFormat: NSLocalizedString(@"%@", nil), region.identifier]
                                           type: TDNotificationTypeSuccess
                                           mode: TDNotificationModeText
                                    dismissible: YES
                                 hideAfterDelay: 10];
    
    // If active alert banner area is hidden from view, scroll ito top
    [self checkViewLocation];
    
    //vibrate the phone to alert the user this also covers the alert if user has phone on silent
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    //Show alert box
    [userAlert show];
    
    //Make phone talk. will add more sounds later with normal local alert.
    [self.alertSynthesizer speakUtterance: utterance];
    
    //Set a custom notification object to show a short notification if the app is in the background
    //Found on gitHub and refrenced in the readMe file
    //This sets a notification handeled in notification manager but created from custom class to override
    //timing issue and allowing the alert to run seconds after this method fires.
    ACPReminder *localNotifications = [ACPReminder sharedManager];
    
    //Settings ACPReminder library -- also added a sound file refrence to the ACPReminder.m file in the method
    // creatLocalNotification:- line no: 103.
    localNotifications.messages = @[[NSString stringWithFormat: NSLocalizedString(@"Arriving at %@", nil), region.identifier], [NSString stringWithFormat: NSLocalizedString(@"Wake Up now\n %@ is coming up next!", nil), region.identifier]];
    localNotifications.timePeriods = @[@(1)]; //seconds after fireing - used as alert when app is in BG
    localNotifications.appDomain = @"nu.mine.powerfamilyau.MyStopMonitor";
    localNotifications.randomMessage = YES; //By default is NO (optional)
    localNotifications.testFlagInSeconds = YES; //By default is NO (optional) --> Used to fake alert to user-temporary!
    
    //create notification which will trigger on phone if app is closed in 1 second i used this custom class to
    //save development time but may choose to re do this in apple standard code in future updates.
    [localNotifications createLocalNotification];
    
    // Update the icon badge number - used more for when application is in the background
    //does run while app is open but when app is switching to background mode this number is reset to 0
	[UIApplication sharedApplication].applicationIconBadgeNumber++;
}

@end
