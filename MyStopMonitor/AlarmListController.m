/*////////////////////////////////////////////////////////////////////////////////
//  AlarmListController.m                                                      //
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

#import "AlarmListController.h"
#import "ACPReminder/ACPReminder.h"
#import "TDNotificationPanel.h"

@implementation AlarmListController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
	
	//!!Create location manager with filters set for battery efficiency.
	self.locManager = [[CLLocationManager alloc] init];
	self.locManager.delegate = self;
	
    self.locManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    //self.locManager.distanceFilter = 10.0f;
    
	self.locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //self.locManager.desiredAccuracy = 20.0f;
	
    //Initalize alertSynth object for user alert to region entry.
    self.alertSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
	//MOVE REGION CREATION TO OWN FILE AND CALL FROM THE ADD STOP CONTROLLER,
    //Start updating location changes.
	[self.locManager startUpdatingLocation];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Alarm"];
    
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest: fetchRequest error: &error];
    
    if(results == nil)
    {
        NSLog(@"Could Not fetch Alarm:\n%@", error.userInfo);
    }
    else if ([results count] == 0)
    {
        self.currentAlarms = [[NSMutableArray alloc] initWithCapacity: 0];
    }
    else
    {
        //Use mutableCopy of Array results as current alarms is a mutable array.
        self.currentAlarms = [results mutableCopy];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	// Get all regions being monitored for this application.
    //NOTE: Will need to Check for is alarm Active switch
	NSMutableArray *regions = [[NSMutableArray alloc] init];
    regions = [[self.locManager monitoredRegions] allObjects].mutableCopy;
	    
	// Iterate through the regions/AlarmStops
    //Possibly only one annotation needed
	for (int i = 0; i < [regions count]; i++)
    {
		CLCircularRegion *region = [regions objectAtIndex: i];
        
		StopAnnotation *annotation = [[StopAnnotation alloc] initWithCLRegion:region aCoord: region.center aTitle: region.identifier andSubtitle: @"Train station"];
        
		// Start monitoring the region.
		[self.locManager startMonitoringForRegion: annotation.region];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //One for alarms and other for count of alarms.
    // This may change to save screen realestate.
    return 2;
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
       static NSString *CellIdentifier = @"AlarmCell";
       AlarmCell *cell = (AlarmCell*)[tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                                    forIndexPath: indexPath];

       // Configure the Alarm cell with alarm details.
       Alarm* a = [self.currentAlarms objectAtIndex: indexPath.row];
    
        cell.alarmSuburbLabel.text = a.station.stationSuburb;
        cell.alarmStopNameLabel.text = a.station.stationName;
        cell.alarmLocationLabel.text = [NSString stringWithFormat:@"%@,\n%@", a.station.stationLatitude, a.station.stationLongitude];

        //Add a switch to the alarm Cell.
        UISwitch *alarmActiveSwitch = [[UISwitch alloc] initWithFrame: CGRectZero];
        
        //Set identifying tag for selecting only that switch.[rowNumber]
        alarmActiveSwitch.tag = indexPath.row;

        //use accessoryView to help position the seitch easily.
        cell.accessoryView = alarmActiveSwitch;
        
        //NSLog(@"The stored Alarm switch value is: %@", a.alarmIsActive);
        
        //Check initial state of alarm switch has it been saved in on or off position.
        //and redo that switch
        if (a.alarmIsActive.integerValue ==  1)
        {
            [alarmActiveSwitch setOn: YES animated: YES];
        }
        else
        {
            [alarmActiveSwitch setOn: NO animated: YES];
        }
        
        [alarmActiveSwitch addTarget: self action: @selector(switchChanged:) forControlEvents: UIControlEventValueChanged];
        
    
       return cell;
    }
    else
    {
        //Total Alarms count cell.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TotalCell"
                                                                forIndexPath: indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Total Alarms Set: %lu", (unsigned long)[self.currentAlarms count]];
        
        return cell;
    }
    
    return nil;
}

//Check to see if activate Alarm Switch has moved  ??Ask about passing in alarm from row.
- (void)switchChanged:(id)sender
{
    UISwitch *switchControl = sender;

    //NSLog( @"The switch is %@", switchControl.on ? @"ON": @"OFF" );

    //Do stuff here when switch is changed to on position:
    //start monitoring region, update the alarmIsActive Value.
    //otherwise stop monitoring for off position.
    if (switchControl.isOn)
    {
        //??pass back value to set alarm is active??
        NSLog(@"Switch is on");

    }
    else
    {
        NSLog(@"switch is off");
    }
    
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
        
        //location coord object and set lat and long to this obj.
        CLLocationCoordinate2D stopCenter;
        stopCenter.latitude = [alarmToRemove.station.stationLatitude doubleValue];
        stopCenter.longitude = [alarmToRemove.station.stationLongitude doubleValue];
        
        // ios7+ Create the geographic circular region to be monitored.
        CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                       initWithCenter: stopCenter
                                       radius: [alarmToRemove.alarmAlertRadius doubleValue]  //will be set by user slider
                                       identifier: alarmToRemove.station.stationName];
        
        //REMOVE EVENT OR REGION MONITORING ENTRY TO STOP MONITORING/ALERTS
        [self.locManager stopMonitoringForRegion: geoRegion];
        
        //remove the alarm object from the currentAlarms
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddAlarmSegue"])
    {
        AddStopController* controller = segue.destinationViewController;
        controller.managedObjectContext = self.managedObjectContext;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"showMapSegue"])
    {
        //set the controller to the segue destination from storyboard
        ShowStopMapViewController* controller = segue.destinationViewController;
        
        //return data from mapView controller.  NOTE: add mapView Delegate to this file .h
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

-(void)addAlarmStop:(Alarm *)anAlarm
{
    //link to switch value to set alarm inactive/off for user to activate later
    anAlarm.alarmIsActive = [NSNumber numberWithInt: 1];
    
    //link to slider to adjust radius of region
    anAlarm.alarmAlertRadius = [NSNumber numberWithFloat: 210.0];  //used in the region creation for radius in meters.
                                                                   //chose 210 to allow enough time for user.
                                                                   //will keep this value as the lowest radius limit.
    
    //date of creation may be used after future update to set repeating alarms.
    anAlarm.alarmTime = [NSDate date];
    
    //set the location manager to this page.
    self.locManager.delegate = self;
    
    //Add the region from the alarm to the locManager Monitor Region.
    [self addAlarmRegion:anAlarm];

    //Add alarm to the array for viewing in the Table View.
    [self.currentAlarms addObject:anAlarm];
    //Reload TableView Data to show new alarm.
    [self.tableView reloadData];
   
    //Set error space to debug any errors
    NSError *error;
    
    //if an error occured when saving to managedObject then show userInfo formated output.
    if(![self.managedObjectContext save: &error])
    {
        NSLog(@"Could not add Station to the alarm:\n%@", error.userInfo);
    }
}

- (void)addAlarmRegion:(Alarm *)anAlarm
{
    //Is region monitoring available for this app?
	if ([CLLocationManager isMonitoringAvailableForClass:[CLRegion class]])
    {
        //Begin monitoring the station region just created in the anAlarm object.
        NSLog(@"Beginning the Region monitoring for location: %@", anAlarm.station.stationName);
        
        //Used in region init and overlay position.
        CLLocationCoordinate2D stopCenter;
        stopCenter.latitude = [anAlarm.station.stationLatitude doubleValue];
        stopCenter.longitude = [anAlarm.station.stationLongitude doubleValue];
        
		// Start location manager monitoring the alarm stop region, radius & ID.
		[self.locManager startMonitoringForRegion: [[CLCircularRegion alloc]
                                                    initWithCenter: stopCenter
                                                    radius: [anAlarm.alarmAlertRadius doubleValue]
                                                    identifier: anAlarm.station.stationName]];
        
        //may change the location changes updates depending on needs Vs Battery.
        [self.locManager startMonitoringSignificantLocationChanges];
	}
	else
    {
		NSLog(@"Region monitoring is not available.");
	}
}

#pragma mark - CLLocationManagerDelegate

//Check monitoring for region has started successfully
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //NSLog(@"\nNow monitoring region named: %@", region.identifier);
}

//if the region monitoring failed then run this delegate method.
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
    
    NSLog(@"Event was: %@", event);
}

//Error checking on region monitoring and iPhone sim error with locations/No GPS
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.userInfo == nil)
    {
        NSLog(@"Location Manager had a error\nDetails: %@", error.userInfo);
    }
    else
    {
        NSLog(@"Location Manager had a error\nDetails: Error may have been caused by iPhone Simulator not having GPS chip?!");
    }
}

//May not be needed at this time.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{

}

//This method will be the one to alert users to station arival!
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	//Debug lines
    NSString *event = [NSString stringWithFormat:@"You've Entered the Region %@ at %@", region.identifier, [NSDate date]];
    NSLog(@"Event was: %@", event);
    

    //--------Alert the user To Region or station arrival with Sound Alert and Vibrate------------
    //Create string to speak with region name or identifier in it.
    NSString *utteranceString = [NSString stringWithFormat: NSLocalizedString(@"Wake up now your almost at %@", nil), region.identifier];
    
    //Create speech object
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString: utteranceString];
    //Voice speed.
    utterance.rate = .2f;
    
    //Create user alert box for station arrival alert
    UIAlertView *userAlert;
    //instanciate the alert
    userAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Stop Monitor Alarm", nil) message:[NSString stringWithFormat:NSLocalizedString(@"%@ is coming up!", nil), region.identifier] delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel Alert", nil) otherButtonTitles: NSLocalizedString(@"OK im awake!", nil), nil];
    
    //In app animation for arrival at station
    [TDNotificationPanel showNotificationInView: self.view
                                          title: NSLocalizedString(@"Next Stop: ", nil)
                                       subtitle: [NSString stringWithFormat: NSLocalizedString(@"%@", nil), region.identifier]
                                           type: TDNotificationTypeSuccess
                                           mode: TDNotificationModeText
                                    dismissible: YES
                                 hideAfterDelay: 10];
    
    //vibrate the phone to alert the user this also covers the alert if user has phone on silent
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    //Show alert box
    [userAlert show];
    
    //Make phone talk. will add more sounds later with normal local alert.
    [self.alertSynthesizer speakUtterance: utterance];
    
    //Set a custom notification object to show a short notification if the app is in the background
    ACPReminder *localNotifications = [ACPReminder sharedManager];
    
    //Settings ACPReminder library --
    #warning - Add ACPReminder refrence to author in comments and project readMe file.
    localNotifications.messages = @[[NSString stringWithFormat: NSLocalizedString(@"Arriving at %@", nil), region.identifier], [NSString stringWithFormat: NSLocalizedString(@"Wake Up now\n %@ is coming up next!", nil), region.identifier]];
    localNotifications.timePeriods = @[@(1)]; //seconds after fireing - used as alert when app is in BG
    localNotifications.appDomain = @"nu.mine.powerfamilyau.MyStopMonitorV1.1";
    localNotifications.randomMessage = YES; //By default is NO (optional)
    localNotifications.testFlagInSeconds = YES; //By default is NO (optional) --> Used to fake alert to user-temporary!
    
    [localNotifications createLocalNotification];
    
    // Update the icon badge number for when app is in b.g.
	[UIApplication sharedApplication].applicationIconBadgeNumber++;

}

//not needed in this application.
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	//NSString *event = [NSString stringWithFormat:@"You Exited the Region %@ at %@", region.identifier, [NSDate date]];
    //NSLog(@"Event was: %@", event);
}
//End CLLocationManager delegate methods.

@end
