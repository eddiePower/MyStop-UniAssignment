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
            [self showFileWithFileName:@"WelcomeInfo"];
            break;
        case 1:
            [self showFileWithFileName:@"AboutInfo"];
            break;
        default:
            break;
    }
    
}

- (void)showFileWithFileName:(NSString *)aName
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:aName ofType:@"html"] isDirectory:NO];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.aboutWebView loadRequest:request];
}

- (IBAction)indexChanged:(UISegmentedControl *)sender
{
    // Do any additional setup after loading the view.
    switch (self.infoTextSegment.selectedSegmentIndex)
    {
        case 0:
            [self showFileWithFileName:@"WelcomeInfo"];
            break;
        case 1:
            [self showFileWithFileName:@"AboutInfo"];
            break;
        default:
            break;
    }
 



}
@end
