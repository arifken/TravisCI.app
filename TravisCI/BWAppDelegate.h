//
//  BWAppDelegate.h
//  TravisCI
//
//  Created by Bradley Grzesiak on 12/19/11.
//  Refer to MIT-LICENSE file at root of project for copyright info
//

#import <UIKit/UIKit.h>
#import <CoreData.h>
#import "PTPusherDelegate.h"

@class BWPusherHandler, BWDetailContainerViewController, BWCDJob, BWFavoriteList;

@interface BWAppDelegate : UIResponder <UIApplicationDelegate, PTPusherDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BWDetailContainerViewController *detailContainerViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) BWPusherHandler *pusherHandler;
@property (nonatomic, strong) BWFavoriteList *favoriteList;

- (void)subscribeToLogChannelForJob:(BWCDJob *)job;
- (void)unsubscribeFromLogChannelForJob:(BWCDJob *)job;


- (void)saveContext;
- (NSURL *)applicationCacheDirectory;

@end
