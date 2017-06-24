//
//  LeaseagramAPHelper.m
//  Leaseagram
//
//  Created by JingChan on 11/20/13.
//  Copyright (c) 2013 fergus. All rights reserved.
//

#import "RentagraphAPHelper.h"

@implementation RentagraphAPHelper

+ (RentagraphAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RentagraphAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.quantumlisting.purchase.onemonthlicense",
                                      @"com.quantumlisting.purchase.threemonthlicense",
                                      @"com.quantumlisting.purchase.oneyearlicense",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
