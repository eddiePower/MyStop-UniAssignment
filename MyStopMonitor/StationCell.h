//  StationCell.h                                                             
//  MyStopMonitor

//  This class is used to layout a prototype Table View Cell
//  that displays a Station's details, this is a subclass of the
//  UITableViewCell class.

//  Created by Eddie Power on 7/05/2014.
//  Copyright (c) 2014 Eddie Power.
//  All rights reserved.

#import <UIKit/UIKit.h>

@interface StationCell : UITableViewCell

//IBoutlet or interfaceBuilder outlet to output data to the screen

@property (weak, nonatomic) IBOutlet UILabel *stopSuburbLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopLatLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopLongLabel;

@end
