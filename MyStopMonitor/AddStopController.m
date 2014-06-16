/*////////////////////////////////////////////////////////////////////////////////
//  AddStopController.m                                                        //
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

#import "AddStopController.h"

@implementation AddStopController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create the pull to refresh control with code not storyboard.
    UIRefreshControl *myRefreshControl = [[UIRefreshControl alloc] init];
    //add a color to the spinner and text.
    myRefreshControl.tintColor = [UIColor colorWithRed:113/255.0 green:83/255.0 blue:245/255.0 alpha:1];
    
    myRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"Checking for new stations.", nil)];
    
    [myRefreshControl addTarget:self action:@selector(refreshStations) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = myRefreshControl;

    //Download and store the station data in the coreData stack.
    [self downloadStationData];
    
    //Fetch station data from the coreData stack
    [self fetchStationData];
}
-(void)refreshStations
{
    NSLog(@"Now downloading any new updates from API");
    //Grab new data from PTV API on user request.
    [self downloadStationData];
    
    //run table update and stop refresh in one method.
    [self performSelector:@selector(updateTable) withObject:nil
           afterDelay:1];
}

- (void)updateTable
{
    //Reload any new results for stations.
    [self.tableView reloadData];
    
    //Stop the refresh task from running.
    [self.refreshControl endRefreshing];
}

-(void)downloadStationData
{
    //initalize objects used for data retrieval from API.
    NSURL *url;
    GenerateSigniture *getSigniture = [[GenerateSigniture alloc] init];
    
    //Core url will eventually be a if statement for different train lines via /line/x/ changing
    //And also /mode/x/ changing for different transport types such as tram, bus, night rider and Vline services.
    url = [getSigniture generateURLWithDevIDAndKey:@"http://timetableapi.ptv.vic.gov.au/v2/mode/0/line/6/stops-for-line"];
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    
    //Create a fetchRequest to check count of objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Station"];
    
    //Set a temp error storage space for count request.
    NSError *error;
    //Store a count of number items returned from managedObjectContext.
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
                 [self parseStationJSON: data];
                 [self fetchStationData];
             }
             else
             {
                 NSLog(@"Connection Error:\n%@", error.userInfo);
             }
         }];
    }
}

-(void)fetchStationData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Station"];
    
    //will try sort these in order of train line real world stops but may need edit core data from set
    // plist of station stop id's in order of real world stop order per trainline.
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"stationStopId" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[nameSort]];
    
    NSError *error;
    
      self.array = [[NSArray alloc] init];
      self.array = [self.managedObjectContext executeFetchRequest: fetchRequest error:&error];
    
    if (self.array == nil)
    {
        NSLog(@"Could not Fetch Station Data:\n%@", error.userInfo);
    }
    
}

-(void)parseStationJSON:(NSData *)data
{
    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error:&error];
    
    if (result == nil)
    {
        NSLog(@"Error parsing JSON data:\n%@", error.userInfo);
        return;
    }
    
    
    if([result isKindOfClass:[NSArray class]])
    {
        NSArray *StationArray = (NSArray *)result;
        NSLog(@"Found %lu Stations!", (unsigned long)[StationArray count]);
        
        for (NSDictionary* station in StationArray)
        {
            Station *aStation = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
            
            aStation.stationName = [station objectForKey:@"location_name"];
            aStation.stationSuburb = [station objectForKey:@"suburb"];
            aStation.stationStopId = [station objectForKey:@"stop_id"];
            aStation.stationStopType = [station objectForKey:@"transport_type"];
            aStation.stationLatitude = [station objectForKey:@"lat"];
            aStation.stationLongitude = [station objectForKey:@"lon"];
            aStation.stationDistance = [station objectForKey:@"distance"];
        }
        
        self.array = StationArray;
        NSLog(@"Number of stops in Array is now: %lu", (long unsigned)[self.array count]);
        NSError *error;
        
        if (![self.managedObjectContext save:&error])
        {
            NSLog(@"Could not save Train Line Stops:\n%@", error.userInfo);
        }
        
    }
    else
    {
        NSLog(@"Unexpected JSON format");
        return;
    }
    
    [self.tableView reloadData];
    
}

//TableView Delegate methods.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of stops for this Train Line object in the section.
    return [self.array count];
}

//Used to display items in the tableView on Add stop Table View.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set the refrence to the cell Identifier and then to the cell.
    static NSString *CellIdentifier = @"StationCell";
    
    StationCell *cell = (StationCell*)[tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                                      forIndexPath: indexPath];
    
    // Configure the cell using the trainLine stops built from coreData or  ... JSON.
    Station *s = [self.array objectAtIndex: indexPath.row];
    
    cell.stopSuburbLabel.text = s.stationSuburb;
    cell.stopNameLabel.text = s.stationName;
    cell.stopLatLabel.text = [NSString stringWithFormat:@"%@", s.stationLatitude];
    cell.stopLongLabel.text = [NSString stringWithFormat:@"%@", s.stationLongitude];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create a temp station object to hold selected station
    Station *selectedStation = [self.array objectAtIndex:indexPath.row];
    
    //create the new alarm object to add the station to.
    Alarm *newAlarm = [NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:self.managedObjectContext];
    
    //combine the two objects or relate them.
    newAlarm.station = selectedStation;
    
    //send the delegate method the new Alarm including selectedStation.
    [self.delegate addAlarmStop: newAlarm];
    //Pop a alarm onto the list.
    [self.navigationController popViewControllerAnimated: YES];
}

@end
