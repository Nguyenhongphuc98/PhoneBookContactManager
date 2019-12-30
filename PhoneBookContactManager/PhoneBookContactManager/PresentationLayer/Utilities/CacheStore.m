//
//  CacheStore.m
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/24/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import "CacheStore.h"

@implementation CacheStore

+ (instancetype)sharedInstance{
    static CacheStore *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedInstance = [[CacheStore alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.interalCache = [[NSCache alloc] init];
    }
    return self;
}

- (NSData *)getImagefor:(NSString *)identifier{
    return [self.interalCache objectForKey:identifier];
}

- (void)setImage:(UIImage *)image for:(NSString *)identidier{
    if(image == nil)
    {
        NSLog(@"set null data for cache store");
        return;
    }
    [self.interalCache setObject:image forKey:identidier];
}
@end
