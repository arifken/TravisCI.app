/*!
 * \file    BWCDMappingHelper
 * \project 
 * \author  Andy Rifken 
 * \date    5/7/13.
 *
 */



#import <Foundation/Foundation.h>

@class RKEntityMapping;
@class RKManagedObjectStore;


@interface BWCDMappingHelper : NSObject

@property(strong) RKManagedObjectStore *managedObjectStore;
@property(strong) RKEntityMapping *repositoryMapping;
@property(strong) RKEntityMapping *buildMapping;
@property(strong) RKEntityMapping *buildJobMapping;

- (id)initWithManagedObjectStore:(RKManagedObjectStore *)managedObjectStore;

+ (id)helperWithManagedObjectStore:(RKManagedObjectStore *)managedObjectStore;


@end