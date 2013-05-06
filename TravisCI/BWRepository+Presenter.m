//
//  BWRepository.m
//  TravisCI
//
//  Created by Bradley Grzesiak on 12/20/11.
//  Refer to MIT-LICENSE file at root of project for copyright info
//

#import "BWRepository+Presenter.h"
#import "CoreData.h"

#import "NSDate+Formatting.h"
#import "BWPresenter.h"
#import "UIAlertView+BWTravisCI.h"

@implementation BWCDRepository (Presenter)

+ (void)fetchRepository:(NSNumber *)remote_id
{
    RKObjectManager *manager = [RKObjectManager sharedManager];

    NSString *resourcePath = [NSString stringWithFormat:@"/repositories/%@.json", remote_id];
//    [manager loadObjectsAtResourcePath:resourcePath
//                         objectMapping:[manager.mappingProvider mappingForKeyPath:@"BWCDRepository"]
//                              delegate:nil];

    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:resourcePath parameters:nil];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:manager.responseDescriptors];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *op, RKMappingResult *mappingResult) {
          // TODO: handle completion block
    } failure:^(RKObjectRequestOperation *op, NSError *error) {
        [UIAlertView showGenericError];
    }];

}

- (void)fetchBuilds
{
    RKObjectManager *manager = [RKObjectManager sharedManager];

    NSString *resourcePath = [NSString stringWithFormat:@"/repositories/%@/builds.json", self.remote_id];
//    [manager loadObjectsAtResourcePath:resourcePath
//                         objectMapping:[manager.mappingProvider mappingForKeyPath:@"BWCDBuild"]
//                              delegate:nil];

    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:resourcePath parameters:nil];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:manager.responseDescriptors];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *op, RKMappingResult *mappingResult) {
          // TODO: handle completion block
    } failure:^(RKObjectRequestOperation *op, NSError *error) {
        [UIAlertView showGenericError];
    }];

}

PRESENT_statusImage
PRESENT_statusTextColor

- (NSString *)finishedText
{
    NSDate *finished = [self last_build_finished_at];
    if (finished != nil) {
        return [finished distanceOfTimeInWords];
    } else {
        return @"-";
    }
}

- (NSString *)durationText
{
    NSNumber *duration = [self last_build_duration];
    if (duration != nil) {
        return [NSDate rangeOfTimeInWordsFromSeconds:[duration intValue]];
    } else {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.last_build_started_at];
        NSInteger timeSinceNow = [[NSNumber numberWithDouble:fabs(interval)] integerValue];
        return [NSDate rangeOfTimeInWordsFromSeconds:timeSinceNow];
    }
}

- (BWStatus)currentStatus
{
    if (self.last_build_result != nil && self.last_build_finished_at) {
        return (self.last_build_result == [NSNumber numberWithInt:0]) ? BWStatusPassed : BWStatusFailed;
    }
    return BWStatusPending;
}

- (NSString *)accessibilityLabel
{
    NSArray *userAndRepo = [self.slug componentsSeparatedByString:@"/"];
    return [NSString stringWithFormat:@"%@ by %@", [userAndRepo objectAtIndex:1], [userAndRepo objectAtIndex:0]];
}

- (NSString *)accessibilityHint
{
    switch (self.currentStatus) {
        case BWStatusPending:
            return @"Most recent build is still building";
            break;
        case BWStatusPassed:
            return [NSString stringWithFormat:@"Most recent build passed %@ and took %@", self.finishedText, self.durationText];
            break;
        case BWStatusFailed:
            return [NSString stringWithFormat:@"Most recent build failed %@ and took %@", self.finishedText, self.durationText];
    }
    return @"";
}

- (NSString *)name
{
    NSArray *slugInfo = [self.slug componentsSeparatedByString:@"/"];
    return [slugInfo objectAtIndex:1];
}

- (NSString *)author
{
    NSArray *slugInfo = [self.slug componentsSeparatedByString:@"/"];
    return [slugInfo objectAtIndex:0];
}

@end
