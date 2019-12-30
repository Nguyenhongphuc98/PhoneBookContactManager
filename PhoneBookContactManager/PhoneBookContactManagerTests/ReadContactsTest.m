//
//  ReadContactsTest.m
//  PhoneBookContactManagerTests
//
//  Created by CPU11716 on 12/23/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DContactStore.h"
@interface ReadContactsTest : XCTestCase
@property DContactStore *t;
@end

@implementation ReadContactsTest

- (void)setUp {
    self.t = [DContactStore sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMultiLoadAtSameTime {
    
    BOOL expectGranted = YES;
    int countcontactIndevice = 6;
    int applyTimes = 50;
    NSInteger expectCountTimesGotData = [[NSNumber numberWithInt:applyTimes] integerValue];
    
    BOOL __block resultGranted;
    NSInteger __block resultCountTimesGotData = [[NSNumber numberWithInt:0] integerValue];
    

        [self.t checkAuthorizeStatus:^(BOOL granted, NSError * _Nonnull error) {
            if(granted)
            {
                resultGranted = YES;
                dispatch_apply(applyTimes, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t size) {
                    
                    [self.t loadContactWithCompleteHandle:^(NSMutableArray * _Nullable arr, NSError * _Nullable error) {
                        if(error)
                        {
                            NSLog(@"err load contact.");
                        }
                        else
                            if(arr != nil && arr.count == countcontactIndevice)
                            {
                                resultCountTimesGotData ++;
                                NSLog(@"got data: %ld",resultCountTimesGotData);
                            }
                            else
                                if(arr==nil)
                                    NSLog(@"ar nil.");
                        
                    }];
                });
            }
            else
            {
                resultGranted = NO;
            }
        }];
    
    //XCTAssertEqual(resultGranted, expectGranted,@"testing permission");
    //XCTAssertEqual(resultCountTimesGotData, expectCountTimesGotData,@"testing getdata");
   
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
