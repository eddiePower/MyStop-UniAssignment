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
        TrainLine *tl1 = [[TrainLine alloc] initWithTrainLineName:@"Alamein" andLineNumber: [NSNumber numberWithInt: 1]];
        TrainLine *tl2 = [[TrainLine alloc] initWithTrainLineName:@"Belgrave" andLineNumber: [NSNumber numberWithInt: 2]];
        TrainLine *tl3 = [[TrainLine alloc] initWithTrainLineName:@"Craigieburn" andLineNumber: [NSNumber numberWithInt: 3]];
        TrainLine *tl4 = [[TrainLine alloc] initWithTrainLineName:@"Cranbourne" andLineNumber: [NSNumber numberWithInt: 4]];
        TrainLine *tl5 = [[TrainLine alloc] initWithTrainLineName:@"South Morang" andLineNumber: [NSNumber numberWithInt: 5]];
        TrainLine *tl6 = [[TrainLine alloc] initWithTrainLineName:@"Frankston" andLineNumber: [NSNumber numberWithInt: 6]];
        TrainLine *tl7 = [[TrainLine alloc] initWithTrainLineName:@"Glen Waverley" andLineNumber: [NSNumber numberWithInt: 7]];
        TrainLine *tl8 = [[TrainLine alloc] initWithTrainLineName:@"Hurstbridge" andLineNumber: [NSNumber numberWithInt: 8]];
        TrainLine *tl9 = [[TrainLine alloc] initWithTrainLineName:@"Lilydale" andLineNumber: [NSNumber numberWithInt: 9]];
        TrainLine *tl10 = [[TrainLine alloc] initWithTrainLineName:@"Pakenham" andLineNumber: [NSNumber numberWithInt: 10]];
        TrainLine *tl11 = [[TrainLine alloc] initWithTrainLineName:@"Sandringham" andLineNumber: [NSNumber numberWithInt: 11]];
        TrainLine *tl12 = [[TrainLine alloc] initWithTrainLineName:@"Stony Point" andLineNumber: [NSNumber numberWithInt: 12]];
        TrainLine *tl13 = [[TrainLine alloc] initWithTrainLineName:@"Sunbury" andLineNumber: [NSNumber numberWithInt: 13]];
        TrainLine *tl14 = [[TrainLine alloc] initWithTrainLineName:@"Upfield" andLineNumber: [NSNumber numberWithInt: 14]];
        TrainLine *tl15 = [[TrainLine alloc] initWithTrainLineName:@"Werribee" andLineNumber: [NSNumber numberWithInt: 15]];
        TrainLine *tl16 = [[TrainLine alloc] initWithTrainLineName:@"Williamstown" andLineNumber: [NSNumber numberWithInt: 16]];
        
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set unchangable string for cell identifier
      static NSString *CellIdentifier = @"TrainLineCell";
    
    TrainLineCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    
    // Configure the cell...
    TrainLine *tmpTLine = [self.allTrainLines objectAtIndex:indexPath.row];
    
    cell.trainLineName.text = tmpTLine.lineName;    
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //check segue name or identifier if it is addAlarmSegue
    if ([segue.identifier isEqualToString:@"AddAlarmSegue"])
    {
        //then set segue destination viewController as AddAlarmStopController
        AddStopController* controller = segue.destinationViewController;
        //pass managed object context from this class to the destination
        // to allow all core data to accessed from the next view.
        controller.managedObjectContext = self.managedObjectContext;
        //set the delegate to the addStopController view.
        
        
        
        // controller.delegate = self;
        
        
        
        //select the index path sent over by sender or cell selected
        NSIndexPath* indexPath = [self.tableView indexPathForCell: sender];
        
        controller.trainLine = [self.allTrainLines objectAtIndex: indexPath.row];
        
    }
}


@end
