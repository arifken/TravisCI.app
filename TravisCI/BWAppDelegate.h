//
//  BWAppDelegate.h
//  TravisCI
//
//  Created by Bradley Grzesiak on 12/19/11.
//  Copyright (c) 2011 Bendyworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestKit/RKObjectLoader.h"
#import "PTPusherDelegate.h"
@class BWPusherHandler, BWDetailContainerViewController, BWJob;

@interface BWAppDelegate : UIResponder <UIApplicationDelegate, RKObjectLoaderDelegate, PTPusherDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BWDetailContainerViewController *detailContainerViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) BWPusherHandler *pusherHandler;

- (void)subscribeToLogChannelForJob:(BWJob *)job;
- (void)unsubscribeFromLogChannelForJob:(BWJob *)job;


- (void)saveContext;
- (NSURL *)applicationCacheDirectory;

@end
