//
//  AMPDatabaseHelperTests.m
//  Amplitude
//
//  Created by Daniel Jih on 9/9/15.
//  Copyright (c) 2015 Amplitude. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMPDatabaseHelper.h"
#import "AMPARCMacros.h"
#import "AMPConstants.h"

@interface AMPDatabaseHelperTests : XCTestCase
@property (nonatomic, strong)  AMPDatabaseHelper *databaseHelper;
@end

@implementation AMPDatabaseHelperTests {}

- (void)setUp {
    [super setUp];
    self.databaseHelper = [AMPDatabaseHelper getDatabaseHelper];
    [self.databaseHelper resetDB:NO];
}

- (void)tearDown {
    [super tearDown];
    [self.databaseHelper deleteDB];
    self.databaseHelper = nil;
}

- (void)testCreate {
    XCTAssertTrue([self.databaseHelper addEvent:@"test"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyValue:@"key" value:@"value"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyLongValue:@"key" value:[NSNumber numberWithLongLong:0LL]]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"identify"]);
}

- (void)testGetEvents {
    NSArray *emptyResults = [self.databaseHelper getEvents:-1 limit:-1];
    XCTAssertEqual(0, [emptyResults count]);

    [self.databaseHelper addEvent:@"{\"event_type\":\"test1\"}"];
    [self.databaseHelper addEvent:@"{\"event_type\":\"test2\"}"];

    // test get all events
    NSArray *events = [self.databaseHelper getEvents:-1 limit:-1];
    XCTAssertEqual(2, events.count);
    XCTAssert([[[events objectAtIndex:0] objectForKey:@"event_type"] isEqualToString:@"test1"]);
    XCTAssertEqual(1, [[[events objectAtIndex:0] objectForKey:@"event_id"] longValue]);
    XCTAssert([[[events objectAtIndex:1] objectForKey:@"event_type"] isEqualToString:@"test2"]);
    XCTAssertEqual(2, [[[events objectAtIndex:1] objectForKey:@"event_id"] longValue]);

    // test get all events up to certain id
    events = [self.databaseHelper getEvents:1 limit:-1];
    XCTAssertEqual(1, events.count);
    XCTAssertEqual(1, [[events[0] objectForKey:@"event_id"] intValue]);

    // test get all events with limit
    events = [self.databaseHelper getEvents:1 limit:1];
    XCTAssertEqual(1, events.count);
    XCTAssertEqual(1, [[events[0] objectForKey:@"event_id"] intValue]);
}

- (void)testGetIdentifys {
    NSArray *emptyResults = [self.databaseHelper getIdentifys:-1 limit:-1];
    XCTAssertEqual(0, [emptyResults count]);
    XCTAssertEqual(0, [self.databaseHelper getTotalEventCount]);

    [self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"];
    [self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"];

    XCTAssertEqual(0, [self.databaseHelper getEventCount]);
    XCTAssertEqual(2, [self.databaseHelper getIdentifyCount]);
    XCTAssertEqual(2, [self.databaseHelper getTotalEventCount]);

    // test get all identify events
    NSArray *events = [self.databaseHelper getIdentifys:-1 limit:-1];
    XCTAssertEqual(2, events.count);
    XCTAssertEqual(2, [[events[1] objectForKey:@"event_id"] intValue]);
    XCTAssert([[[events objectAtIndex:0] objectForKey:@"event_type"] isEqualToString:IDENTIFY_EVENT]);
    XCTAssertEqual(1, [[[events objectAtIndex:0] objectForKey:@"event_id"] longValue]);
    XCTAssert([[[events objectAtIndex:1] objectForKey:@"event_type"] isEqualToString:IDENTIFY_EVENT]);
    XCTAssertEqual(2, [[[events objectAtIndex:1] objectForKey:@"event_id"] longValue]);

    // test get all identify events up to certain id
    events = [self.databaseHelper getIdentifys:1 limit:-1];
    XCTAssertEqual(1, events.count);
    XCTAssertEqual(1, [[events[0] objectForKey:@"event_id"] intValue]);

    // test get all identify events with limit
    events = [self.databaseHelper getIdentifys:1 limit:1];
    XCTAssertEqual(1, events.count);
    XCTAssertEqual(1, [[events[0] objectForKey:@"event_id"] intValue]);
}

- (void)testInsertAndReplaceKeyValue {
    NSString *key = @"test_key";
    NSString *value1 = @"test_value1";
    NSString *value2 = @"test_value2";
    XCTAssertNil([self.databaseHelper getValue:key]);

    [self.databaseHelper insertOrReplaceKeyValue:key value:value1];
    XCTAssert([[self.databaseHelper getValue:key] isEqualToString:value1]);

    [self.databaseHelper insertOrReplaceKeyValue:key value:value2];
    XCTAssert([[self.databaseHelper getValue:key] isEqualToString:value2]);
}

- (void)testInsertAndReplaceKeyLongValue {
    NSString *key = @"test_key";
    NSNumber *value1 = [NSNumber numberWithLongLong:1LL];
    NSNumber *value2 = [NSNumber numberWithLongLong:2LL];
    XCTAssertNil([self.databaseHelper getLongValue:key]);

    [self.databaseHelper insertOrReplaceKeyLongValue:key value:value1];
    XCTAssert([[self.databaseHelper getLongValue:key] isEqualToNumber:value1]);

    [self.databaseHelper insertOrReplaceKeyLongValue:key value:value2];
    XCTAssert([[self.databaseHelper getLongValue:key] isEqualToNumber:value2]);

    NSString *boolKey = @"bool_value";
    NSNumber *boolValue = [NSNumber numberWithBool:YES];
    [self.databaseHelper insertOrReplaceKeyLongValue:boolKey value:boolValue];
    XCTAssertTrue([[self.databaseHelper getLongValue:boolKey] boolValue]);
}

- (void)testEventCount {
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test1\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test2\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test3\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test4\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test5\"}"]);

    XCTAssertEqual(5, [self.databaseHelper getEventCount]);

    [self.databaseHelper removeEvent:1];
    XCTAssertEqual(4, [self.databaseHelper getEventCount]);

    [self.databaseHelper removeEvents:3];
    XCTAssertEqual(2, [self.databaseHelper getEventCount]);

    [self.databaseHelper removeEvents:10];
    XCTAssertEqual(0, [self.databaseHelper getEventCount]);
}

- (void)testIdentifyCount {
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);

    XCTAssertEqual(0, [self.databaseHelper getEventCount]);
    XCTAssertEqual(5, [self.databaseHelper getIdentifyCount]);
    XCTAssertEqual(5, [self.databaseHelper getTotalEventCount]);

    [self.databaseHelper removeIdentify:1];
    XCTAssertEqual(4, [self.databaseHelper getIdentifyCount]);

    [self.databaseHelper removeIdentifys:3];
    XCTAssertEqual(2, [self.databaseHelper getIdentifyCount]);

    [self.databaseHelper removeIdentifys:10];
    XCTAssertEqual(0, [self.databaseHelper getIdentifyCount]);
}

- (void)testGetNthEventId {
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test1\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test2\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test3\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test4\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test5\"}"]);

    XCTAssertEqual(1, [self.databaseHelper getNthEventId:0]);
    XCTAssertEqual(1, [self.databaseHelper getNthEventId:1]);
    XCTAssertEqual(2, [self.databaseHelper getNthEventId:2]);
    XCTAssertEqual(3, [self.databaseHelper getNthEventId:3]);
    XCTAssertEqual(4, [self.databaseHelper getNthEventId:4]);
    XCTAssertEqual(5, [self.databaseHelper getNthEventId:5]);

    [self.databaseHelper removeEvent:1];
    XCTAssertEqual(2, [self.databaseHelper getNthEventId:1]);

    [self.databaseHelper removeEvents:3];
    XCTAssertEqual(4, [self.databaseHelper getNthEventId:1]);

    [self.databaseHelper removeEvents:10];
    XCTAssertEqual(-1, [self.databaseHelper getNthEventId:1]);
}

- (void)testGetNthIdentifyId {
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);

    XCTAssertEqual(1, [self.databaseHelper getNthIdentifyId:0]);
    XCTAssertEqual(1, [self.databaseHelper getNthIdentifyId:1]);
    XCTAssertEqual(2, [self.databaseHelper getNthIdentifyId:2]);
    XCTAssertEqual(3, [self.databaseHelper getNthIdentifyId:3]);
    XCTAssertEqual(4, [self.databaseHelper getNthIdentifyId:4]);
    XCTAssertEqual(5, [self.databaseHelper getNthIdentifyId:5]);

    [self.databaseHelper removeIdentify:1];
    XCTAssertEqual(2, [self.databaseHelper getNthIdentifyId:1]);

    [self.databaseHelper removeIdentifys:3];
    XCTAssertEqual(4, [self.databaseHelper getNthIdentifyId:1]);

    [self.databaseHelper removeIdentifys:10];
    XCTAssertEqual(-1, [self.databaseHelper getNthIdentifyId:1]);
}

- (void)testNoConflictBetweenEventsAndIdentifys{
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test1\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test2\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test3\"}"]);
    XCTAssertTrue([self.databaseHelper addEvent:@"{\"event_type\":\"test4\"}"]);
    XCTAssertEqual(4, [self.databaseHelper getEventCount]);
    XCTAssertEqual(0, [self.databaseHelper getIdentifyCount]);

    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"{\"event_type\":\"$identify\"}"]);
    XCTAssertEqual(4, [self.databaseHelper getEventCount]);
    XCTAssertEqual(2, [self.databaseHelper getIdentifyCount]);

    [self.databaseHelper removeEvent:1];
    XCTAssertEqual(3, [self.databaseHelper getEventCount]);
    XCTAssertEqual(2, [self.databaseHelper getIdentifyCount]);

    [self.databaseHelper removeIdentify:1];
    XCTAssertEqual(3, [self.databaseHelper getEventCount]);
    XCTAssertEqual(1, [self.databaseHelper getIdentifyCount]);

    [self.databaseHelper removeEvents:4];
    XCTAssertEqual(0, [self.databaseHelper getEventCount]);
    XCTAssertEqual(1, [self.databaseHelper getIdentifyCount]);
}

- (void)testUpgradeFromVersion0ToVersion2{
    // inserts will fail since no tables exist
    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper addEvent:@"test_event"]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper insertOrReplaceKeyValue:@"test_key" value:@"test_value"]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper insertOrReplaceKeyLongValue:@"test_key" value:[NSNumber numberWithInt:0]]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper addIdentify:@"test_identify"]);

    // after upgrade, can insert into event, store, long_store
    [self.databaseHelper dropTables];
    XCTAssertTrue([self.databaseHelper upgrade:0 newVersion:2]);
    XCTAssertTrue([self.databaseHelper addEvent:@"test"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyValue:@"key" value:@"value"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyLongValue:@"key" value:[NSNumber numberWithLongLong:0LL]]);

    // still can't insert into identify
    XCTAssertFalse([self.databaseHelper addIdentify:@"test_identify"]);
}

// should be exact same as upgrading from 0 to 2
- (void)testUpgradeFromVersion1ToVersion2{
    // inserts will fail since no tables exist
    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper addEvent:@"test_event"]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper insertOrReplaceKeyValue:@"test_key" value:@"test_value"]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper insertOrReplaceKeyLongValue:@"test_key" value:[NSNumber numberWithInt:0]]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper addIdentify:@"test_identify"]);

    // after upgrade, can insert into event, store, long_store
    [self.databaseHelper dropTables];
    XCTAssertTrue([self.databaseHelper upgrade:1 newVersion:2]);
    XCTAssertTrue([self.databaseHelper addEvent:@"test"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyValue:@"key" value:@"value"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyLongValue:@"key" value:[NSNumber numberWithLongLong:0LL]]);

    // still can't insert into identify
    XCTAssertFalse([self.databaseHelper addIdentify:@"test_identify"]);
}

- (void)testUpgradeFromVersion2ToVersion3 {
    [self.databaseHelper dropTables];
    [self.databaseHelper upgrade:1 newVersion:2];

    // can insert into events, store, long_store
    XCTAssertTrue([self.databaseHelper addEvent:@"test"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyValue:@"key" value:@"value"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyLongValue:@"key" value:[NSNumber numberWithLongLong:0LL]]);

    // insert into identifys fail since table doesn't exist yet
    XCTAssertFalse([self.databaseHelper addIdentify:@"test_identify"]);

    // after upgrade, can insert into identify
    [self.databaseHelper dropTables];
    [self.databaseHelper upgrade:1 newVersion:2];
    [self.databaseHelper upgrade:2 newVersion:3];
    XCTAssertTrue([self.databaseHelper addEvent:@"test"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyValue:@"key" value:@"value"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyLongValue:@"key" value:[NSNumber numberWithLongLong:0LL]]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"test_identify"]);
}

- (void)testUpgradeFromVersion0ToVersion3 {
    // inserts will fail since no tables exist
    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper addEvent:@"test_event"]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper insertOrReplaceKeyValue:@"test_key" value:@"test_value"]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper insertOrReplaceKeyLongValue:@"test_key" value:[NSNumber numberWithInt:0]]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper addIdentify:@"test_identify"]);

    // after upgrade, can insert into event, store, long_store, identify
    [self.databaseHelper dropTables];
    XCTAssertTrue([self.databaseHelper upgrade:0 newVersion:3]);
    XCTAssertTrue([self.databaseHelper addEvent:@"test"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyValue:@"key" value:@"value"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyLongValue:@"key" value:[NSNumber numberWithLongLong:0LL]]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"test_identify"]);
}

// should be exact same as upgrading from 0 to 3
- (void)testUpgradeFromVersion1ToVersion3 {
    // inserts will fail since no tables exist
    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper addEvent:@"test_event"]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper insertOrReplaceKeyValue:@"test_key" value:@"test_value"]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper insertOrReplaceKeyLongValue:@"test_key" value:[NSNumber numberWithInt:0]]);

    [self.databaseHelper dropTables];
    XCTAssertFalse([self.databaseHelper addIdentify:@"test_identify"]);

    // after upgrade, can insert into event, store, long_store, identify
    [self.databaseHelper dropTables];
    XCTAssertTrue([self.databaseHelper upgrade:1 newVersion:3]);
    XCTAssertTrue([self.databaseHelper addEvent:@"test"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyValue:@"key" value:@"value"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyLongValue:@"key" value:[NSNumber numberWithLongLong:0LL]]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"test_identify"]);
}

- (void)testUpgradeFromVersion3ToVersion3{
    // upgrade does nothing, can insert into event, store, long_store, identify
    [self.databaseHelper dropTables];
    XCTAssertTrue([self.databaseHelper upgrade:3 newVersion:3]);
    XCTAssertTrue([self.databaseHelper addEvent:@"test"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyValue:@"key" value:@"value"]);
    XCTAssertTrue([self.databaseHelper insertOrReplaceKeyLongValue:@"key" value:[NSNumber numberWithLongLong:0LL]]);
    XCTAssertTrue([self.databaseHelper addIdentify:@"test"]);
}

@end
