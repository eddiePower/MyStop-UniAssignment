//
//  Alarm.h
//  MyStopMonitor

//  The class is used to create Alarm objects that are in turn used
//  to store the users alert details to core data, this is an auto
//   generated class by the Core Data Model and is a subclass of NSManagedObject.
//  It refrences data types compatible with CD and also refrences a Station object

//  Created by Eddie Power on 11/06/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Station;

@interface Alarm : NSManagedObject

@property (nonatomic, retain) NSNumber * alarmAlertRadius;
@property (nonatomic, retain) NSNumber * alarmIsActive;
@property (nonatomic, retain) NSDate * alarmTime;
@property (nonatomic, retain) NSString * alarmTitle;
@property (nonatomic, retain) Station *station;

@end
