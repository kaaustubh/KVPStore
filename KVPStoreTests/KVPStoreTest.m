//
//  KVPStoreTest.m
//  KVPStore
//
//  Created by Kaustubh on 30/09/15.
//  Copyright (c) 2015 VW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KVPStore.h"

#define kObjectKey @"Series"
#define kValueKey  @"Name"
#define kValue     @"Walter White"


@interface KVPStoreTest : XCTestCase
{
    KVPStore *sharedInstance;
}

@end

@implementation KVPStoreTest

- (void)setUp {
    [super setUp];
    sharedInstance=[KVPStore sharedManager];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testSetValue
{
    [sharedInstance setValue:kValue forKey:kValueKey];
    NSDictionary * value= [sharedInstance valueForKey:kValueKey];
    if([value[@"value"] caseInsensitiveCompare:kValue] == NSOrderedSame)
        XCTAssert(YES, @"Pass");
    else
        XCTFail(@"Failed");
}

-(void)testSetObjectForKey
{
    id returnValue;
    NSArray *testArr=[[NSArray alloc] initWithObjects:@"Everybody",@"Lies",  nil];
    [sharedInstance setObject:testArr forKey:@"Series"];
    returnValue= [sharedInstance objectForKey:@"Series"];
    if (returnValue)
    {
        NSArray *resultArr=returnValue[@"value"];
        NSString *string=@"";
        for (NSString *str in resultArr)
        {
            string=[string stringByAppendingString:str];
        }
        
        if ([string caseInsensitiveCompare:@"EverybodyLies"] == NSOrderedSame)
        {
            XCTAssert(YES, @"Pass- Its nothing personal, I don't like anybody");
        }
        else
        {
            XCTFail(@"Failed- Things change, it doesnt mean that they get better and this test is screwed");
        }
    }
    else
    {
        XCTFail(@"Failed");
    }
}

-(void)testRemoveValueForKey
{
    [sharedInstance removeValueForKey:kValueKey];
    NSDictionary * value= [sharedInstance valueForKey:kValueKey];
    if(value[@"value"])
        XCTFail(@"Failed");
    else
        XCTAssert(YES, @"Pass");
}

-(void)testRemoveObjectForKey
{
    [sharedInstance removeValueForKey:kObjectKey];
    NSDictionary * value= [sharedInstance valueForKey:kObjectKey];
    if(value[@"value"])
        XCTFail(@"Failed");
    else
        XCTAssert(YES, @"Pass");
}

-(void)testGetAllRows
{
    NSArray *testArr=[[NSArray alloc] initWithObjects:@"Everybody",@"Lies",  nil];
    [sharedInstance setObject:testArr forKey:@"Series"];
    [sharedInstance setValue:kValue forKey:kValueKey];
    
    NSArray *arr=[sharedInstance allObjects];
    if (arr.count)
    {
        XCTAssert(YES, @"Pass");
    }
    else
    {
        XCTFail(@"Failed");
    }
}

-(void)testCount
{
    NSArray *testArr=[[NSArray alloc] initWithObjects:@"Everybody",@"Lies",  nil];
    [sharedInstance setObject:testArr forKey:@"Series"];
    [sharedInstance setValue:kValue forKey:kValueKey];
    NSUInteger count=[sharedInstance count];
    if (count==2)
    {
         XCTAssert(YES, @"Pass");
    }
    else
    {
        XCTFail(@"Failed");
    }
}

@end
