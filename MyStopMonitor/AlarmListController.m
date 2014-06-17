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
    
    //Initalize alertSynth object for user alert to region entry.
    self.alertSynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    self.locManager.delegate = self;
    
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
    //Display the monitored regions after loading or reloading the view.
    if ([self.locManager monitoredRegions].count > 0)
    {
        //NSLog(@"Region List is now: %@", [self.locManager monitoredRegions]);
    }
    else
    {
        //NSLog(@"No Regions bieng monitored at this time.");
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

        //use accessoryView to help position the seitch easily.
        cell.accessoryView = alarmActiveSwitch;
        cell.alarmSwitch = alarmActiveSwitch;
        cell.cellAlarm = a;
        
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
        //Total Alarms count cell.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TotalCell"
                                                                forIndexPath: indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Total Alarms Set: %lu", (unsigned long)[self.currentAlarms count]];
        
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
    
    //geographic circular region to be removed.
    CLCircularRegion *geoRegion = [[CLCircularRegion alloc]
                                   initWithCenter: stopCenter
                                   radius: [anAlarm.alarmAlertRadius doubleValue]
                                   identifier: anAlarm.station.stationName];
        
    //REMOVE EVENT OR REGION MONITORING ENTRY TO STOP MONITORING/ALERTS
    [self.locManager stopMonitoringForRegion: geoRegion];
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

//Add the station item to the new alarm object,
//add the station location as a region for monitoring.
-(void)addAlarmStop:(Alarm *)anAlarm
{
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //link to switch value to set alarm inactive/off for user to activate later
    anAlarm.alarmIsActive = [NSNumber numberWithInt: 1];
    
    //link to slider to adjust radius of region
    anAlarm.alarmAlertRadius = [defaults objectForKey:@"alertRadius"];  //used in the region creation for radius in meters.
                                                                        //chose 360m-900m to allow enough time for user.
                                                                        //will keep this value as the last set radius limit.
    
    //date of creation may be used after future update to set repeating alarms.
    anAlarm.alarmTime = [NSDate date];
    
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

- (void)addAlarmRegion:(Alarm *)anAlarm
{
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tempString = [defaults objectForKey:@"alertRadius"];
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

//CLLocationManagerDelegate

//Check monitoring for region has started successfully
-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //NSLog(@"\nNow monitoring region named: %@", region.identifier);
}

-(void)locationManager:(CLLocationManager *)manager didStopMonitoringForRegion:(CLRegion *)region
{
    //NSLog(@"\nStoping monitoring region name: %@", region.identifier);
}
//if the region monitoring failed then run this delegate method.
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
	NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
    
    NSLog(@"Event was: %@\n\nError details: %@", event, error.userInfo);
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
    NSLog(@"\nEvent was: %@", event);
    
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
    
    //In app animation for arrival at station appears at top of view for 10 seconds, refrenced in ReadMe.txt file.
    [TDNotificationPanel showNotificationInView: self.view
                                          title: NSLocalizedString(@"Next Stop: ", nil)
                                       subtitle: [NSString stringWithFormat: NSLocalizedString(@"%@", nil), region.identifier]
                                           type: TDNotificationTypeSuccess
                                           mode: TDNotificationModeText
                                    dismissible: YES
                                 hideAfterDelay: 10];

    // If active alert banner area is hidden from view, scroll ito top
    //first and if at x:0, y:-80 then dont scroll up anymore
    if (self.tableView.contentOffset.y != -80)
    {
       [self.tableView setContentOffset:CGPointMake(0, -80) animated:YES];
    }
    
    //vibrate the phone to alert the user this also covers the alert if user has phone on silent
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    //Show alert box
    [userAlert show];
    
    //Make phone talk. will add more sounds later with normal local alert.
    [self.alertSynthesizer speakUtterance: utterance];
    
    //Set a custom notification object to show a short notification if the app is in the background
    ACPReminder *localNotifications = [ACPReminder sharedManager];
    
    //Settings ACPReminder library --
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
