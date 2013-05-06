/*!
 * \file    NSManagedObject(BWTravisCI)
 * \project 
 * \author  Andy Rifken 
 * \date    5/6/13.
 *
 */



#import <Foundation/Foundation.h>

@interface NSManagedObject (BWTravisCI)
+ (id)findFirstByAttribute:(NSString *)attr withValue:(id)val inContext:(NSManagedObjectContext *)context;
+ (id)createEntityInContext:(NSManagedObjectContext *)context;
@end