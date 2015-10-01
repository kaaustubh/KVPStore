//
//  KVPStore.m
//  KVPStore
//
//  Created by Kaustubh on 30/09/15.
//  Copyright (c) 2015 VW. All rights reserved.
//

#import "KVPStore.h"
#import "DBManager.h"



@interface KVPStore(NSKeyValueCoding)


@end

@implementation KVPStore

static KVPStore *sharedInstance;

+(instancetype)sharedManager
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[super allocWithZone:NULL]init];
        }});
    return sharedInstance;
}

-(instancetype)initWithSQLFile:(NSString *)sqliteFile
{
    self = [super init];
    
    return self;
}

- (id)valueForKey:(NSString *)key
{
    __block NSDictionary *value;
    @synchronized(self)
    {
        DBManager *shareinstance=[DBManager shareInstance];
        NSArray *arr=[shareinstance queryDatabaseForkey:key];
        value=[arr firstObject];
   }
    
    return value;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    @synchronized(self)
    {
        DBManager *shareinstance=[DBManager shareInstance];
        [shareinstance queryDatabaseWithkey:key data:[self getArchiveObject:value]];
    }
}

- (NSData *)getArchiveObject:(id)object
{
    return [NSKeyedArchiver archivedDataWithRootObject:object];
}

-(void)setObject:(id)object forKey:(NSString *)key
{
    @synchronized(self)
    {
        DBManager *shareinstance=[DBManager shareInstance];
        [shareinstance queryDatabaseWithkey:key data:[self getArchiveObject:object]];
    }
}
               
-(id)objectForKey:(NSString *)key
{
    __block NSDictionary *value;
    @synchronized(self)
    {
        DBManager *shareinstance=[DBManager shareInstance];
        NSArray *arr=[shareinstance queryDatabaseForkey:key];
        value=[arr firstObject];
    }
    
    return value;
}

-(void)removeObjectForKey:(NSString *)key
{
    @synchronized(self)
    {
        DBManager *shareinstance=[DBManager shareInstance];
        [shareinstance removeFromDataBase:key];
    }
}

-(void)removeValueForKey:(NSString *)key
{
    @synchronized(self)
    {
        DBManager *shareinstance=[DBManager shareInstance];
        [shareinstance removeFromDataBase:key];
    }
}

-(NSArray*)allObjects
{
    __block NSArray *resultArr;
    @synchronized(self)
    {
        DBManager *shareinstance=[DBManager shareInstance];
        resultArr=[shareinstance getAllRows];
    }
    return resultArr;
}

-(NSUInteger)count
{
    __block NSArray *resultArr;
    NSUInteger count=0;
    @synchronized(self)
    {
        DBManager *shareinstance=[DBManager shareInstance];
        resultArr=[shareinstance getAllRows];
    }
    
    count=resultArr.count;
    return count;
}

@end
