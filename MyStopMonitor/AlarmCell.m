/*////////////////////////////////////////////////////////////////////////////////
//  AlarmCell.m                                                                //
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

#import "AlarmCell.h"

@implementation AlarmCell

-(void)setupCell
{
    [self.alarmSwitch addTarget: self action: @selector(toggleAlarm) forControlEvents:UIControlEventValueChanged];
}

-(void)toggleAlarm
{
    if(self.alarmSwitch.on)
    {
        //Update the value stored in alarmIsactive property part of the Alarm class
        self.cellAlarm.alarmIsActive = [NSNumber numberWithInt:1];
       
        //NSLog(@"In AlarmCell.m:toggleAlarm: alarm is now active, value is: %@\nStation name is: %@", self.cellAlarm.alarmIsActive, self.cellAlarm.station.stationName);
        
        //Search the managed object context sent over from alarmListViewController which is recieved initially from app delegate file. then update value of alarmIsActive key in managedobject context
        [self updateAlarmManagedObject: [NSNumber numberWithInt:1] objectToSearchFor: self.cellAlarm.station.stationName];
        
        #warning fill in switch region alert off with switch here!!
        //check for region alert for this cellAlarm
        
        AlarmListController *testing = [[AlarmListController alloc] init];
        
        [testing  addAlarmRegion: self.cellAlarm];

        //else add region via alarm object then return.
    }
    else
    {
        //Update the value stored in alarmIsactive property part of the Alarm class
        self.cellAlarm.alarmIsActive = [NSNumber numberWithInt: 0];
        
        //Search the managed object context sent over from alarmListViewController which is recieved initially from app delegate file. then update value of alarmIsActive key in managedobject context
        [self updateAlarmManagedObject: [NSNumber numberWithInt:0] objectToSearchFor: self.cellAlarm.station.stationName];
        
        
        
        //Remover region alert
        //REMOVE EVENT OR REGION MONITORING ENTRY TO STOP MONITORING/ALERTS
        AlarmListController *testing = [[AlarmListController alloc] init];
        [testing removeStopRegion: self.cellAlarm];

    }
}

//This will update values already in the managedObjectContext by taking in a value from an id object
// this allows it to be any data type i need to update and
-(void)updateAlarmManagedObject:(NSNumber *)isActiveValue objectToSearchFor:(NSString *)alarmTitle
{
    
    
    //This first bit i got lazy and couldnt work out how to pass managedObject here as its in my
    //AlarmCell prototype file not a ViewController so its in a tableView not a normall view
    // Elliott said this was a specific fix for mine
    
    //Set up the first view controller location.
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navController = [tabController.viewControllers firstObject];
    
    //Set the AlarmListController which uses the Core Data stack similar to app delegate.
    AlarmListController *alarmListController = [navController.viewControllers firstObject];
    self.managedObjectContext = alarmListController.managedObjectContext;
    //End elliotts specific fix
    
    
    //Create a fetchRequest to setEntity or edit entity in Alarm
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Alarm" inManagedObjectContext: self.managedObjectContext]];
    
    //create predecate to search for the alarmTitle passed into this method
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"alarmTitle == %@", alarmTitle];
    //set predecate on request
    [request setPredicate: predicate];
    
    NSError *error = nil;
    //Run request
    NSArray *results = [self.managedObjectContext executeFetchRequest: request error: &error];
    
    // maybe some check before, to be sure results is not empty
    NSManagedObject* AlarmGrabbed = [results objectAtIndex: 0];
    NSLog(@"\n\n\nAlarm retrieved from MoC: %@", AlarmGrabbed);
    
    
    // error handling code
    //if an error occured when saving to managedObject then show userInfo formated output.
    //Otherwise save the newly update managedObjectContext.
    if(![self.managedObjectContext save: &error])
    {
      NSLog(@"Could not add Station to the alarm:\n%@", error.userInfo);
    }
    
}


@end
