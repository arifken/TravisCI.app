//
//  BWPusherHandler.m
//  TravisCI
//
//  Created by Bradley Grzesiak on 12/21/11.
//  Copyright (c) 2011 Bendyworks. All rights reserved.
//

#import "BWPusherHandler.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "BWCommandBuildStarted.h"
#import "BWCommandBuildFinished.h"
#import "BWCommandJobFinished.h"
#import "BWCommandJobLog.h"

#import "RestKit/RestKit.h"

#define PUSHER_EVENT_LOGGING 0



@interface BWPusherHandler()
- (void)setupPusherWithKey:(NSString *)apiKey;
@end



@implementation BWPusherHandler
@synthesize client, subscribedChannels;

+ (id)pusherHandlerWithKey:(NSString *)apiKey
{
    BWPusherHandler *pusherHandler = [[BWPusherHandler alloc] initWithKey:apiKey];
    return pusherHandler;
}

- (id)initWithKey:(NSString *)apiKey
{
    self = [super init];
    if (self != nil) {
        self.subscribedChannels = [NSMutableDictionary dictionary];
        [self setupPusherWithKey:apiKey];
    }
    return self;
}

- (void)setupPusherWithKey:(NSString *)apiKey
{
    self.client = [PTPusher pusherWithKey:apiKey delegate:self];
    self.client.reconnectAutomatically = YES;
    
    PTPusherChannel *channel = [self.client subscribeToChannelNamed:@"common"];
    
    [channel bindToEventNamed:@"build:started" target:[[BWCommandBuildStarted alloc] init] action:@selector(buildWasStarted:)];
    [channel bindToEventNamed:@"build:finished" target:[[BWCommandBuildFinished alloc] init] action:@selector(buildWasFinished:)];
    [channel bindToEventNamed:@"job:finished" target:[[BWCommandJobFinished alloc] init] action:@selector(jobWasFinished:)];

#if PUSHER_EVENT_LOGGING
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEvent:) name:PTPusherEventReceivedNotification object:channel];
#endif

}

- (void)subscribeToChannel:(NSString *)channelName
{
    NSLog(@"subscribing to %@", channelName);
    PTPusherChannel *channel = [self.client subscribeToChannelNamed:channelName];
    [self.subscribedChannels setValue:channel forKey:channelName];

    [channel bindToEventNamed:@"job:log" target:[[BWCommandJobLog alloc] init] action:@selector(jobLogAppended:)];
}

- (void)unsubscribeFromChannel:(NSString *)channelName
{
    NSLog(@"unsubscribing from %@", channelName);
    [self.client unsubscribeFromChannel:[self.subscribedChannels valueForKey:channelName]];
}

- (void)didReceiveEvent:(NSNotification *)note
{
    PTPusherEvent *event = (PTPusherEvent *)[[note userInfo] valueForKey:PTPusherEventUserInfoKey];
    NSLog(@"pusher - notification: %@", [event data]);
}

#pragma mark - Pusher Delegate methods

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection { NSLog(@"pusher - did connect: %@", connection); }
- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel { NSLog(@"pusher - did subscribe to channel: %@", channel); }
- (void)pusher:(PTPusher *)pusher didUnsubscribeToChannel:(PTPusherChannel *)channel { NSLog(@"pusher - did unsubscribe to channel: %@", channel); }

@end
