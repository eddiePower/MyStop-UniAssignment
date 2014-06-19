//
//  StopMonitorInfoViewController.h
//  MyStopMonitor
//
//  Created by Eddie Power on 18/06/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopMonitorInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *infoTextSegment;

@property (strong, nonatomic) IBOutlet UIWebView *aboutWebView;



@property(strong, nonatomic) NSAttributedString *welcomeText;
@property(strong, nonatomic) NSAttributedString *aboutText;


- (IBAction)indexChanged:(UISegmentedControl *)sender;

@end
