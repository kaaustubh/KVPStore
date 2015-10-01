//
//  KVPStore.h
//  KVPStore
//
//  Created by Kaustubh on 30/09/15.
//  Copyright (c) 2015 VW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVPStore : NSObject

+(instancetype)sharedManager;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)removeValueForKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (NSArray *)allObjects;
- (NSUInteger)count;

@end
