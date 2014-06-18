//
//  StopMonitorInfoViewController.m
//  MyStopMonitor
//
//  Created by Eddie Power on 18/06/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.
//

#import "StopMonitorInfoViewController.h"

@interface StopMonitorInfoViewController ()

@end

@implementation StopMonitorInfoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    switch (self.infoTextSegment.selectedSegmentIndex)
    {
        case 0:
            self.infoTextView.text = @"First selected";
            break;
        case 1:
            self.infoTextView.text = @"Second Segment selected";
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)indexChanged:(UISegmentedControl *)sender
{
    switch (self.infoTextSegment.selectedSegmentIndex)
    {
        case 0:
            self.infoTextView.text = @"First selected";
            break;
        case 1:
            self.infoTextView.text = @"Second Segment selected";
            break;
        default: 
            break; 
    }
}
@end
