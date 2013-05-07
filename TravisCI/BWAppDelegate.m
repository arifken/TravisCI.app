//
//  BWAppDelegate.m
//  TravisCI
//
//  Created by Bradley Grzesiak on 12/19/11.
//  Refer to MIT-LICENSE file at root of project for copyright info
//

#import "BWAppDelegate.h"
#import "BWRepositoryListViewController.h"
#import "BWDetailContainerViewController.h"
#import "BWPusherHandler.h"
#import "BWFavoriteList.h"
#import "BWJob+presenter.h"
#import "BWTimeStampFile.h"
#import "BWCDMappingHelper.h"
#import <RestKit/RestKit.h>

@interface BWAppDelegate()
- (void)setupRestKit;
- (void)prepareViewController;
- (void)cleanCacheIfNeeded;
@end

@implementation BWAppDelegate

@synthesize window = _window;
@synthesize detailContainerViewController = _detailContainerViewController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;

@synthesize pusherHandler = _pusherHandler;
@synthesize favoriteList = _favoriteList;

// these PUSHER_API_KEY values are not sensitive to exposure
#ifdef TEST_MODE
    #define TRAVIS_CI_URL @"http://localhost"
    #define PUSHER_API_KEY @"19623b7a28de248aef28"
#else
    #define TRAVIS_CI_URL @"https://api.travis-ci.org"
    #define PUSHER_API_KEY @"23ed642e81512118260e"
#endif

#define TRAVIS_CI_CD_FILE_NAME @"TravisCI-cache.sqlite"
#define CACHE_EXPIRATION_IN_SECONDS 28800


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self cleanCacheIfNeeded];
    [self setupRestKit];
    [self prepareViewController];
    self.pusherHandler = [BWPusherHandler pusherHandlerWithKey:PUSHER_API_KEY];
    self.favoriteList = [[BWFavoriteList alloc] init];
    [self.favoriteList synchronize];
    return YES;
}

- (void)cleanCacheIfNeeded
{
    if ([BWTimeStampFile secondsSinceAppLastClosed] > CACHE_EXPIRATION_IN_SECONDS) {
        [NSFetchedResultsController deleteCacheWithName:nil]; // deletes all previously saved NSFetchedResults caches
        NSError *error = nil;
        NSURL *cd_file = [[self applicationCacheDirectory] URLByAppendingPathComponent:TRAVIS_CI_CD_FILE_NAME];
        [[NSFileManager defaultManager] removeItemAtURL:cd_file error:&error];
        if (error) {
            NSLog(@"ERROR removing cache: %@", error);
        }
    }
}

- (void)setupRestKit
{


//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);


    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:TRAVIS_CI_URL]]; // sets up singleton shared object manager

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    manager.managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSURL *cd_file = [[self applicationCacheDirectory] URLByAppendingPathComponent:TRAVIS_CI_CD_FILE_NAME];


    NSError *error = nil;
    NSPersistentStore *store = [manager.managedObjectStore addSQLitePersistentStoreAtPath:[cd_file path] fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (!store) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", cd_file, error);
    }

    [manager.managedObjectStore createManagedObjectContexts];

    BWCDMappingHelper *mappingHelper = [[BWCDMappingHelper alloc] initWithManagedObjectStore:manager.managedObjectStore];


    RKResponseDescriptor *repoResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mappingHelper.repositoryMapping
                                                                                       pathPattern:@"/repositories.json"
                                                                                           keyPath:nil
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *buildResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mappingHelper.buildMapping
                                                                                            pathPattern:@"/builds/:id.json"
                                                                                                keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *jobResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mappingHelper.buildJobMapping
                                                                                            pathPattern:@"/jobs/:id.json"
                                                                                                keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];



    [manager addResponseDescriptorsFromArray:@[
            repoResponseDescriptor, buildResponseDescriptor, jobResponseDescriptor
    ]];

}

- (void)prepareViewController
{
    if (IS_IPAD) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        self.detailContainerViewController = (id)navigationController.topViewController;

        UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
        BWRepositoryListViewController *controller = (BWRepositoryListViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        BWRepositoryListViewController *controller = (BWRepositoryListViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

- (void)subscribeToLogChannelForJob:(BWCDJob *)job
{
    NSString *channelName = [NSString stringWithFormat:@"job-%d", [job.remote_id integerValue]];
    [self.pusherHandler subscribeToChannel:channelName];
}

- (void)unsubscribeFromLogChannelForJob:(BWCDJob *)job
{
    NSString *channelName = [NSString stringWithFormat:@"job-%d", [job.remote_id integerValue]];
    [self.pusherHandler unsubscribeFromChannel:channelName];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [BWTimeStampFile touchTimeStampFile];
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [BWTimeStampFile touchTimeStampFile];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) { return __managedObjectContext; }
    __managedObjectContext = [[RKObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext];
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) { return __managedObjectModel; }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TravisCI" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Network failure messages

// --V-- this is now a block callback
//- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
//{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
//                                                    message:@"Could not connect to the Travis CI service"
//                                                   delegate:nil
//                                          cancelButtonTitle:@"Bummer"
//                                          otherButtonTitles:nil];
//    [alert show];
//}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                    message:@"Could not connect to the Travis CI realtime service"
                                                   delegate:nil
                                          cancelButtonTitle:@"Bummer"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
