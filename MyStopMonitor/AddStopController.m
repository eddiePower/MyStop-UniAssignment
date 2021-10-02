//  AddStopController.m                                                        
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

#import "AddStopController.h"

@implementation AddStopController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Grab the index number from the row selected in the TrainLine list
    //to set the correct line number (i.e: Frankston is line 6 or row 6)
    
    
    
    
    //Set the searchbar delegate target to this view Controller.
    self.searchBar.delegate = self;
    
    //create a gesture listening object and set the action to dismissKeyboard method.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    //set number of taps to listen for
    tap.numberOfTapsRequired = 2;
    //add regocnizer to the view.
    [self.view addGestureRecognizer:tap];
    
    
    //Create the pull to refresh control with code not storyboard.
    UIRefreshControl *myRefreshControl = [[UIRefreshControl alloc] init];
    //add a color to the spinner and text.
    myRefreshControl.tintColor = [UIColor colorWithRed:113/255.0 green:83/255.0 blue:245/255.0 alpha:1];
    
    myRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"Checking for new stations.", nil)];
    
    [myRefreshControl addTarget:self action:@selector(refreshStations) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = myRefreshControl;

    
    //When the view loads we want to fetch all stations from CD ready for searching
    [self fetchStationDataByName:@""];
    
    //Download and store the station data in the coreData stack.
    [self downloadStationData];
    
    //Fetch station data from the coreData stack
    //[self fetchStationData];
    
}

//fetch station by name, used for search bar
-(void)fetchStationDataByName:(NSString*)name
{
    //The fetch request, asking for MonsterData entities
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Station"];
    
    //If the name string isn't empty...
    if(![name isEqualToString:@""])
    {
        //...we use a Predicate to select the correct station based on the search name
        NSPredicate* nameSelect = [NSPredicate predicateWithFormat:@"stationName contains[cd] %@", name];
        [fetchRequest setPredicate:nameSelect];
    }
    
    //The sort descriptor is used to arrange the results based on name (alphabetically)
    NSSortDescriptor* nameSort = [NSSortDescriptor sortDescriptorWithKey:@"stationName" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameSort]];
    
    //We attempt to execute the fetch request
    NSError* error;
    
    self.stationsArray = [[NSArray alloc] init];
    self.stationsArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    //Deal with errors
    if(self.stationsArray == nil)
    {
        NSLog(@"Could not fetch station Data:\n%@", error.userInfo);
    }
    
    //Reload the table with new data
    [self.tableView reloadData];
}

//Used in the pull to refresh controll for station list.
-(void)refreshStations
{
    NSLog(@"Now downloading any new updates from API");
    //Grab new data from PTV API on user request.
    [self downloadStationData];
    
    //run table update and stop refresh in one method.
    [self performSelector:@selector(updateTable) withObject:nil
           afterDelay:1];
}

//Used to complete the pull to refresh update
- (void)updateTable
{
    //Reload any new results/stations in tableView.
    [self.tableView reloadData];
    
    //Stop the refresh task from running.
    [self.refreshControl endRefreshing];
}

//Get the stations from the PTV API
-(void)downloadStationData
{
    //initalize objects used for data retrieval or url signing from API.
    NSURL *url;
    GenerateSigniture *getSigniture = [[GenerateSigniture alloc] init];
    NSString *lineNumber = @"6"; //hardcoded to frankston line for now.
    
    
    //http://timetableapi.ptv.vic.gov.au/v3/stops/route/6/route_type/0?devid=1000113&signature=FCD2311AEC1222AC07DDEB6CB7D3BCABB84A1910

    //Core url will eventually be a method or if statement for different train lines via /line/x/ query string
    //And also /mode/x/ changing for different transport types such as tram, bus, night rider and Vline services.
    url = [getSigniture generateURLWithDevIDAndKey:[NSString stringWithFormat:@"https://timetableapi.ptv.vic.gov.au/v3/stops/route/%@/route_type/0", lineNumber]];
    
    //request the url object
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    
    //Create a fetchRequest to check count of objects in CD, may change this to use userDefaults firstRun
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Station"];
    
    //Set a temp error storage space for count request.
    NSError *error;
    //Store a count of number station items returned from managedObjectContext.
    NSUInteger count = [self.managedObjectContext countForFetchRequest: fetchRequest
                                                                 error: &error];
    
    //Check the ManagedObjectContext Objects count if its 0
    // then download new copy of stations otherwise use the ones
    //saved in core Data. unless there is an error then go back to
    if (count == 0)
    {
        //Do the download from API
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if(error == nil)  //No errors in data download & parse it to C.D.
             {
                //If there is no error we will parse the response (which will save it into CoreData)
                int numberOfItems = [self parseStationJSON: data];
                 
                //Fetch the stop object from search and load them into the table
                if(numberOfItems > 0)
                    [self fetchStationDataByName: self.searchBar.text];
             }
             else
             {
                 NSLog(@"Connection Error:\n%@", error.userInfo);
             }
         }];
    }
}

//pase or save JSON data to array and tableView.
-(int)parseStationJSON:(NSData *)data
{
    //error storage
    NSError *error;
    //store JSON data into an id or no data type variable
    id result = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error:&error];
    
    //check result has somthing stored in it
    if (result == nil)
    {
        NSLog(@"Error parsing JSON data:\n%@", error.userInfo);
        return 0;
    }
    
    id val = nil;
    NSArray *values = [result allValues];
    val = [values objectAtIndex:0];
    
    //check its class type and if its an Array then save to MoC
    if([val isKindOfClass:[NSArray class]])
    {
        NSArray *StationArray = (NSArray *)val;
        NSLog(@"Found %lu Stations!", (unsigned long)[StationArray count]);
        
        //Store each station from stationArray in a NSDict called station
        for (NSDictionary* station in StationArray)
        {
            //create station object to store in MoC or CD
            Station *aStation = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
            
            //set values for station object from station dictionary with objectForKey method
            aStation.stationName = [station objectForKey:@"stop_name"];
            aStation.stationSuburb = [station objectForKey:@"stop_suburb"];
            aStation.stationStopId = [station objectForKey:@"stop_id"];
            aStation.stationStopType = [station objectForKey:@"transport_type"];
            aStation.stationLatitude = [station objectForKey:@"stop_latitude"];
            aStation.stationLongitude = [station objectForKey:@"stop_longitude"];
            aStation.stationDistance = [station objectForKey:@"distance"];
        }
        
        //store stationArray contents into stationsArray tableView contents
        self.stationsArray = StationArray;
        NSError *error;
        
        //save updates to MoC with checking for errors.
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Could not save Train Line Stops:\n%@", error.userInfo);
        }
        
        //return the number of stations created
        return (int)[StationArray count];
    }
    else
    {
        //error control
        NSLog(@"Unexpected JSON format");
        return 0;
    }
    
    //reload the data in the table view for the user.
    [self.tableView reloadData];
}

//TableView lifeCycle Delegate methods.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of stops for this Train Line object in the section.
    return [self.stationsArray count];
}

//Used to display items in the tableView on Add stop Table View.  tableView data delegate methods.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set the refrence to the cell Identifier and then to the cell.
    static NSString *CellIdentifier = @"StationCell";
    
    //deque a prototype cell for population with data.
    StationCell *cell = (StationCell*)[tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                                      forIndexPath: indexPath];
    
    // Configure the cell using the station built from coreData.
    Station *s = [self.stationsArray objectAtIndex: indexPath.row];
    
    //set cell display values
    cell.stopSuburbLabel.text = s.stationSuburb;
    cell.stopNameLabel.text = s.stationName;
    
    //Calculate the distance from user to station
    //set up and grab the user location from locManager.
    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    //request permission to use location manager if user has not already granted it.
    [locManager requestAlwaysAuthorization];
#endif
    //set up a station 2D coord.
    CLLocationCoordinate2D center;
    center.latitude = [s.stationLatitude doubleValue];
    center.longitude = [s.stationLongitude doubleValue];
    
    //fill out the distance between user local and station.
    cell.stopDistance.text = [NSString stringWithFormat:@"Distance: %.2f km's away", [self kilometersfromPlace: locManager.location.coordinate andToPlace: center]];
    
    //stop updating user location for now.
    [locManager stopUpdatingLocation];
    
    return cell;
}

//tableview did select row used to pass station data to the delegate method.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create a temp station object to hold selected station
    Station *selectedStation = [self.stationsArray objectAtIndex:indexPath.row];
    
    //create the new alarm object to add the station to.
    Alarm *newAlarm = [NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.managedObjectContext];
    
    //combine the two objects or relate them.
    newAlarm.station = selectedStation;
    
    //Calculate the distance from user to station
    //set up and grab the user location from locManager.
    CLLocationManager *locManager = [[CLLocationManager alloc] init];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    //request permission to use location manager if user has not already granted it.
    [locManager requestAlwaysAuthorization];
#endif
    
    //set up a station 2D coord.
    CLLocationCoordinate2D center;
    center.latitude = [selectedStation.stationLatitude doubleValue];
    center.longitude = [selectedStation.stationLongitude doubleValue];
    
    //fill out the distance between user local and station.
    newAlarm.alarmDistance = [NSString stringWithFormat: @"%.2f km's away", [self kilometersfromPlace: locManager.location.coordinate andToPlace: center]];

    //stop updating location for now as we have got the user
    // location to compare to stop location ie: distance between a & b
    [locManager stopUpdatingLocation];
    
    //send the delegate method the new Alarm including selectedStation.
    [self.delegate addAlarmStop: newAlarm];
    //Pop a alarm onto the list.
    [self.navigationController popViewControllerAnimated: YES];
}
//End table view delegate functions

//Translates the searchbarText on the fly rather then after an event like touchUpInside of button
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //run the fetchStationData by name method on changed value of text in searchbar.
    [self fetchStationDataByName: searchText];
}


//Used to calc the distance between two locations in this case the user location and the station in question.
-(float)kilometersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to
{
    
    CLLocation *userLoc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *stationLoc = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userLoc distanceFromLocation: stationLoc]/1000;
    
    //NSLog(@"Distance between is: %f km's away.", dist);
    
    NSString *distance = [NSString stringWithFormat:@"%f",dist];
    
    return [distance floatValue];
    
}


//Keyboard delegate methods
//Hide kb when bg is tapped 2X
- (void) dismissKeyboard
{
    // add searchbar dissmissKeyboard when method is called.
    [self.searchBar resignFirstResponder];
}
//hide when enter or search is tapped
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //hide keyboard by changing or resigning the first responder
    // from the keyboard after the search or return button is tapped.
    [searchBar resignFirstResponder];
}

@end
