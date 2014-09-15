//
//  Alarm.h
//  MyStopMonitor
//
//  Created by Eddie Power on 15/09/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Station;

@interface Alarm : NSManagedObject

@property (nonatomic, retain) NSNumber * alarmAlertRadius;
@property (nonatomic, retain) NSNumber * alarmIsActive;
@property (nonatomic, retain) NSDate * alarmTime;
@property (nonatomic, retain) NSString * alarmTitle;
@property (nonatomic, retain) NSString * alarmDistance;
@property (nonatomic, retain) Station *station;

@end
