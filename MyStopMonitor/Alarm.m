//  Alarm.m
//  MyStopMonitor

//  The class is used to create Alarm objects that are in turn used
//  to store the users alert details to core data, this is an auto
//   generated class by the Core Data Model and is a subclass of NSManagedObject.
//  It refrences data types compatible with CD and also refrences a Station object

//  Created by Eddie Power on 11/06/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.

#import "Alarm.h"
#import "Station.h"


@implementation Alarm

//dynamic meaning pulled from core data similar to a database

@dynamic alarmAlertRadius;
@dynamic alarmIsActive;
@dynamic alarmTime;
@dynamic alarmTitle;
@dynamic station;

@end
