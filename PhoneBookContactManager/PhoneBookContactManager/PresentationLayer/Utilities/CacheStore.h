//
//  CacheStore.h
//  PhoneBookContactManager
//
//  Created by CPU11716 on 12/24/19.
//  Copyright © 2019 CPU11716. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface CacheStore : NSObject

@property NSCache* interalCache;

+ (instancetype) sharedInstance;

- (instancetype) init;

- (UIImage*) getImagefor:(NSString *) identifier;

- (void) setImage:(UIImage *) image for:(NSString *) identidier;

@end

NS_ASSUME_NONNULL_END
