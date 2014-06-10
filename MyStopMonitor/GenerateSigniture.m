/*////////////////////////////////////////////////////////////////////////////////
//  GenerateSigniture.m                                                        //
//  MyStopMonitor                                                             //
//                                                                           //
//  This project is to use the ios core location to monitor a users         //
//  location while on public transport in this case a train running        //
//  on the Frankston Line and a user will set the stop they would         //
//  like to be notified before they reach, the phone will then           //
//  alert the user to the upcoming stop and they can wake up or         //
//  prepare to disembark the train with lots of time and not           //////////
//  missing there stop. This will be widened to accept multiple               //
//  train lines and transport types in an upcoming update soon.              //
//                                                                          //
//  The above copyright notice and this permission notice shall            //
//  be included in all copies or substantial portions of the              //
//  Software.                                                            //
//                                                                      //
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY          //
//  KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE        //
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR          //
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE              //
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,          //
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF           //
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN       //
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER            //
//  DEALINGS IN THE SOFTWARE.                                  //
//                                                            //
//  Created by Eddie Power on 7/05/2014.                     //
//  Copyright (c) 2014 Eddie Power.                         //
//  All rights reserved.                                   //
////////////////////////////////////////////////////////////*/

#import "GenerateSigniture.h"

@implementation GenerateSigniture

-(NSURL*) generateURLWithDevIDAndKey: (NSString*)urlPath
{
    //MY PTV API detils and main url
    NSString *hardcodedURL = @"http://timetableapi.ptv.vic.gov.au";
    NSString *hardcodedDevID = @"1000113";
    NSString *hardcodedkey = @"bfd79740-b866-11e3-8bed-0263a9d0b8a0";
    
    //Set the delete range or amount to the length of the hardcoded url string
    NSRange deleteRange = { 0,[hardcodedURL length] };
    NSMutableString *urlString = [[NSMutableString alloc] initWithString: urlPath];
    
    [urlString deleteCharactersInRange: deleteRange];
    
    if([urlString hasSuffix:@"?"])
        [urlString appendString:@"&"];
    else
        [urlString appendString:@"?"];
    
    [urlString appendFormat:@"devid=%@", hardcodedDevID];
    
    const char *cKey = [hardcodedkey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [urlString cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    
    hash = output;
    NSString* signature = [hash uppercaseString];
    NSString *urlSuffix = [NSString stringWithFormat:@"devid=%@&signature=%@", hardcodedDevID,signature];
    NSURL *url = [NSURL URLWithString:urlPath];
    NSString *urlQuery = [url query];
    
    if(urlQuery != nil && [urlQuery length] > 0)
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@",urlPath,urlSuffix]];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlPath,urlSuffix]];
    }
    
    //NSString *tmpString = [url absoluteString];
    
    //self.signedURL = tmpString;
    
    return url;
}

@end
