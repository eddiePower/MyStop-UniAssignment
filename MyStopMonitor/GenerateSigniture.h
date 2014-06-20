//  GenerateSigniture.h
//  MyStopMonitor

//   This class is used to generate the signiture needed to get data from
//   the PTV api, it uses the full url as input and breaks that down into
//   a base url, developerID, developer key to generate the signiture that is
//   appended to the url required.  It does this by using the SHA1 encryption
//   methods from the CommonCrypto/CommonHMAC.h library. This was addapted from the
//   PTV API read me document examples.

//   Created by Eddie Power on 7/05/2014.
//   Copyright (c) 2014 Eddie Power.
//   All rights reserved.

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonHMAC.h>

@interface GenerateSigniture : NSObject

//Method to create a signiture string for url and return full url
-(NSURL*) generateURLWithDevIDAndKey: (NSString*)urlPath;

@end
