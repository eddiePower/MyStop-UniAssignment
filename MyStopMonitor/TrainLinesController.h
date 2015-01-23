//
//  TrainLinesController.h
//  MyStopMonitor
//
//  Created by Eddie Power on 9/09/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TrainLine.h"
#import "TrainLineCell.h"
#import "AddStopController.h"

@interface TrainLinesController : UITableViewController

@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic) NSArray *allTrainLines;

@end
