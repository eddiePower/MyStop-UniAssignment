//
//  TrainLinesController.m
//  MyStopMonitor
//
//  Created by Eddie Power on 9/09/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.
//

#import "TrainLinesController.h"


@implementation TrainLinesController


- (void)viewDidLoad
{
    [super viewDidLoad];
  
    
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    //build array of all train lines for Melbourne Australia,
    /* 
       Alamein, Belgrave, Craigieburn, Cranbourne, South Morang, Frankston, Glen Waverley, Hurstbridge, Lilydale, Pakenham, Sandringham, Stony Point, Sunbury, Upfield, Werribee and Williamstown
    */
    
    if (self = [super initWithCoder:aDecoder])
    {
        TrainLine *tl1 = [[TrainLine alloc] initWithTrainLineName:@"Alamein"];
        TrainLine *tl2 = [[TrainLine alloc] initWithTrainLineName:@"Belgrave"];
        TrainLine *tl3 = [[TrainLine alloc] initWithTrainLineName:@"Craigieburn"];
        TrainLine *tl4 = [[TrainLine alloc] initWithTrainLineName:@"Cranbourne"];
        TrainLine *tl5 = [[TrainLine alloc] initWithTrainLineName:@"South Morang"];
        TrainLine *tl6 = [[TrainLine alloc] initWithTrainLineName:@"Frankston"];
        TrainLine *tl7 = [[TrainLine alloc] initWithTrainLineName:@"Glen Waverley"];
        TrainLine *tl8 = [[TrainLine alloc] initWithTrainLineName:@"Hurstbridge"];
        TrainLine *tl9 = [[TrainLine alloc] initWithTrainLineName:@"Lilydale"];
        TrainLine *tl10 = [[TrainLine alloc] initWithTrainLineName:@"Pakenham"];
        TrainLine *tl11 = [[TrainLine alloc] initWithTrainLineName:@"Sandringham"];
        TrainLine *tl12 = [[TrainLine alloc] initWithTrainLineName:@"Stony Point"];
        TrainLine *tl13 = [[TrainLine alloc] initWithTrainLineName:@"Sunbury"];
        TrainLine *tl14 = [[TrainLine alloc] initWithTrainLineName:@"Upfield"];
        TrainLine *tl15 = [[TrainLine alloc] initWithTrainLineName:@"Werribee"];
        TrainLine *tl16 = [[TrainLine alloc] initWithTrainLineName:@"Williamstown"];
        
        self.allTrainLines = [NSArray arrayWithObjects: tl1, tl2, tl3, tl4, tl5, tl6, tl7,
                              tl8, tl9, tl10, tl11, tl12, tl13, tl14, tl15, tl16, nil];
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.allTrainLines count];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set unchangable string for cell identifier
      static NSString *CellIdentifier = @"TrainLineCell";
    TrainLineCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
