/*!
 * \file    BWCDMappingHelper
 * \project 
 * \author  Andy Rifken 
 * \date    5/7/13.
 *
 */



#import "RKRelationshipMapping.h"
#import "BWCDMappingHelper.h"
#import "RKEntityMapping.h"
#import "RKManagedObjectStore.h"


@implementation BWCDMappingHelper
- (id)initWithManagedObjectStore:(RKManagedObjectStore *)managedObjectStore {
    self = [super init];
    if (self) {
        self.managedObjectStore = managedObjectStore;


        RKEntityMapping *repositoryMapping = [RKEntityMapping mappingForEntityForName:@"BWCDRepository" inManagedObjectStore:managedObjectStore];
        repositoryMapping.identificationAttributes = @[@"remote_id"];
        [repositoryMapping addAttributeMappingsFromArray:@[@"slug", @"last_build_started_at", @"last_build_finished_at", @"last_build_duration", @"last_build_id", @"last_build_language", @"last_build_number", @"last_build_result", @"last_build_status"]];
        [repositoryMapping addAttributeMappingsFromDictionary:@{
                @"id" : @"remote_id",
                @"description" : @"remote_description",
        }];


        RKEntityMapping *buildMapping = [RKEntityMapping mappingForEntityForName:@"BWCDBuild" inManagedObjectStore:managedObjectStore];
        buildMapping.identificationAttributes = @[@"remote_id"];
        [buildMapping addAttributeMappingsFromArray:@[@"duration",@"finished_at",@"number",@"result",@"started_at",
                                        @"state", @"status", @"author_email", @"author_name", @"branch",
                                        @"committed_at", @"committer_email", @"committer_name", @"compare_url",
                                        @"message", @"commit", @"repository_id"]];
        [buildMapping addAttributeMappingsFromDictionary:@{
                @"id" : @"remote_id"
        }];



        RKEntityMapping *buildJobMapping = [RKEntityMapping mappingForEntityForName:@"BWCDJob" inManagedObjectStore:managedObjectStore];
        [buildJobMapping addAttributeMappingsFromArray:@[@"config", @"finished_at", @"log", @"number", @"repository_id", @"result", @"started_at", @"state", @"status"]];
        [buildJobMapping addAttributeMappingsFromDictionary:@{
                @"id" : @"remote_id"
        }];
        buildJobMapping.identificationAttributes = @[@"remote_id"];

        [buildMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"matrix" toKeyPath:@"jobs" withMapping:buildJobMapping]];


        [buildMapping addRelationshipMappingWithSourceKeyPath:@"repository" mapping:repositoryMapping];
        [buildMapping addConnectionForRelationship:@"repository" connectedBy:@"remote_id"];

        self.repositoryMapping = repositoryMapping;
        self.buildMapping = buildJobMapping;
        self.buildJobMapping = buildJobMapping;

    }

    return self;
}

+ (id)helperWithManagedObjectStore:(RKManagedObjectStore *)managedObjectStore {
    return [[self alloc] initWithManagedObjectStore:managedObjectStore];
}



@end