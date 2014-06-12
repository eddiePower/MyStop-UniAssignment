/*////////////////////////////////////////////////////////////////////////////////
//  AlarmCell.h                                                                //
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

#import <UIKit/UIKit.h>
#import "Alarm.h"
#import "Station.h"
#import "AlarmListController.h"

@interface AlarmCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *alarmSuburbLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmStopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmLocationLabel;
@property (strong, nonatomic) UISwitch *alarmSwitch;
@property (strong, nonatomic) Alarm* cellAlarm;

@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;


-(void)setupCell;

@end
