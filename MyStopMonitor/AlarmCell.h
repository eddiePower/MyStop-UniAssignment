//  AlarmCell.h
//  MyStopMonitor

//  This class is used to lay out a prototype table view cell
//  that will display an Alarm details this also uses the ManagedObjectContext
//  which is a temp storage space for CoreData objects to be worked on before
//  saving them. I also used this class to set and retrieve switch states for
//   each alarm cell to engage or disengage the region monitoring for that alarm,
//  this is why the MoC object is refrenced in this class. This is a subclass of
//  the UITableViewCell class.

//  Created by Eddie Power on 7/05/2014.
//  Copyright (c) 2014 Eddie Power.
//  All rights reserved.

#import <UIKit/UIKit.h>
#import "Alarm.h"
#import "Station.h"
#import "AlarmListController.h"

@interface AlarmCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *alarmSuburbLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmStopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmLocationLabel;

//switch properties needed to get and set switch state
@property (strong, nonatomic) UISwitch *alarmSwitch;
@property (strong, nonatomic) Alarm *cellAlarm;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//setup the cells with labels and switch and logig to set switch state.
-(void)setupCell;

@end
