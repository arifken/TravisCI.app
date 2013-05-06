/*!
 * \file    UIAlertView(BWTravisCI)
 * \project 
 * \author  Andy Rifken 
 * \date    5/6/13.
 *
 */



#import "UIAlertView+BWTravisCI.h"


@implementation UIAlertView (BWTravisCI)

+ (void) showGenericError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:@"Could not connect to the Travis CI service"
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
    [alert show];
}
@end