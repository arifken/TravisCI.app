/*!
 * \file    NSManagedObject(BWTravisCI)
 * \project 
 * \author  Andy Rifken 
 * \date    5/6/13.
 *
 */



#import <RestKit/RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>
#import "NSManagedObject+BWTravisCI.h"


@implementation NSManagedObject (BWTravisCI)


+ (id)findFirstByAttribute:(NSString *)attr withValue:(id)val inContext:(NSManagedObjectContext *)context {
    if (!attr || !val) {
        return nil;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attr, val];
    [fetchRequest setFetchLimit:1];

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];

    if (results && [results count] > 0) {
        return [results objectAtIndex:0];
    }

    return nil;
}


+ (id)createEntityInContext:(NSManagedObjectContext *)context {
    return [context insertNewObjectForEntityForName:NSStringFromClass([self class])];
}

@end