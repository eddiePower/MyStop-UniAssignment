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
    //refrence the alarmListController to make use of methods for adding and removing region alerts via the switch
    AlarmListController *testing = [[AlarmListController alloc] init];
    //create memory space for locManager from alarmList.
    testing.locManager = [[CLLocationManager alloc] init];
    
    if(self.alarmSwitch.on)
    {
        //Update the value stored in alarmIsactive property part of the Alarm class
        self.cellAlarm.alarmIsActive = [NSNumber numberWithInt:1];

        //Search the managed object context sent over from alarmListViewController which is recieved initially from app delegate file. then update value of alarmIsActive key in managedobject context
        [self updateAlarmManagedObject: [NSNumber numberWithInt:1] objectToSearchFor: self.cellAlarm.station.stationName];
        
        //run the addAlarmRegion method from the testing object
        [testing addAlarmRegion: self.cellAlarm];
    }
    else
    {
        //Update the value stored in alarmIsactive property part of the Alarm class
        self.cellAlarm.alarmIsActive = [NSNumber numberWithInt: 0];
        
        //Search the managed object context sent over from alarmListViewController which is recieved initially from app delegate file. then update value of alarmIsActive key in managedobject context
        [self updateAlarmManagedObject: [NSNumber numberWithInt:0] objectToSearchFor: self.cellAlarm.station.stationName];
        
        //Remover region or user alert for a specific stop
        [testing removeStopRegion: self.cellAlarm];

    }
}

//This will update values already in the managedObjectContext by taking in a value from an id object
// this allows it to be any data type i need to update and
-(void)updateAlarmManagedObject:(NSNumber *)isActiveValue objectToSearchFor:(NSString *)alarmTitle
{
    //Set up the first view controller location.
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navController = [tabController.viewControllers firstObject];
    
    //Set the AlarmListController which uses the Core Data stack similar to app delegate.
    AlarmListController *alarmListController = [navController.viewControllers firstObject];
    self.managedObjectContext = alarmListController.managedObjectContext;
    
    
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
    //NSManagedObject* AlarmGrabbed = [results objectAtIndex: 0];
    //NSLog(@"\n\n\nAlarm retrieved from MoC: %@", AlarmGrabbed);
    
    if (results != nil && results > 0)
    {
        // error handling code
        //if an error occured when saving to managedObject then show userInfo formated output.
        //Otherwise save the newly update managedObjectContext.
        if(![self.managedObjectContext save: &error])
        {
            NSLog(@"Could not Save Alarm is active edit because of error:\n%@", error.userInfo);
        }
    }
    else
    {
        NSLog(@"Could not find alarm details in MoC error occured!");
    }    
}


@end
