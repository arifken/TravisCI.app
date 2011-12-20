#import "Kiwi.h"
#import "BWRepository.h"
#import "BWRepository+Private.h"

SPEC_BEGIN(BWRepositorySpec)

describe(@"BWRepository", ^{

    __block BWRepository *subject = nil;

    beforeEach(^{
        subject = [[BWRepository alloc] init];
    });
    
    describe(@"durationText", ^{
        context(@"not finished", ^{
            
        });
        context(@"finished", ^{
            xit(@"returns the formatted time difference between started and finished", ^{
                NSString *expected = @"About 1 minute";

                [subject stub:@selector(last_build_duration) andReturn:[NSNumber numberWithInt:60]];

                NSString *actual = [subject durationText];
                
                [[actual should] equal:expected];
            });
        });
        
    });

});

SPEC_END