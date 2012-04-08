//
//  AZSocketIOTests.m
//  AZSocketIO
//
//  Created by Patrick Shields on 4/6/12.
//  Copyright (c) 2012 Rally Software. All rights reserved.
//

#import "Kiwi.h"
#import "AZSocketIO.h"

SPEC_BEGIN(Tests)
describe(@"The socket", ^{
    __block AZSocketIO *socket;
    context(@"before connection", ^{
        it(@"should be constructable", ^{
            socket = [[AZSocketIO alloc] initWithHost:@"localhost" andPort:@"9000"];
            [socket shouldNotBeNil];
        });
        it(@"should give an error when attempting to send", ^{
            NSError *error = nil;
            [socket send:@"Hi" error:&error];
            [[error.description should] beNonNil];
        });
    });
    context(@"when connecting", ^{
        __block NSDictionary *args;
        __block NSNumber *connected;
        it(@"can connect", ^{
            [socket connectWithSuccess:^{
                connected = [NSNumber numberWithBool:YES];
                socket.eventRecievedBlock = ^(NSString *name, id _args) {
                    args = _args;
                };
            } andFailure:^(NSError *error) {
                connected = [NSNumber numberWithBool:NO];
            }];
            [[expectFutureValue(connected) shouldEventuallyBeforeTimingOutAfter(5.0)] equal:[NSNumber numberWithBool:YES]];
        });
        it(@"recieves an initial event", ^{
            [[expectFutureValue(args) shouldEventuallyBeforeTimingOutAfter(5.0)] beNonNil];
        });
    });
    context(@"after connecting", ^{
        it(@"can send a message and recieve the return val", ^{
            __block NSString *sent = @"FOO";
            __block NSString *recieved;
            socket.eventRecievedBlock = ^(NSString *name, id _args) {
                recieved = [_args objectAtIndex:0];
            };
            [socket send:sent error:nil];
            [[expectFutureValue(recieved) shouldEventuallyBeforeTimingOutAfter(5.0)] equal:sent];
        });
        it(@"can send a json message and recieve the return val", ^{
            __block NSDictionary *sent = [NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"];;
            __block NSDictionary *recieved;
            socket.eventRecievedBlock = ^(NSString *name, id _args) {
                recieved = [_args objectAtIndex:0];
            };
            [socket send:sent error:nil];
            [[expectFutureValue(recieved) shouldEventuallyBeforeTimingOutAfter(5.0)] equal:sent];
        });
    });
});
SPEC_END