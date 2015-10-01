//
//  DBManager.h
//  KVPStore
//
//  Created by Kaustubh on 30/09/15.
//  Copyright (c) 2015 VW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import <sqlite3.h>

@interface DBManager : NSObject

+(instancetype)shareInstance;
-(sqlite3 *)openDatabase;
- (void)closeDatabase:(sqlite3 *)db;
- (void)queryDatabaseWithkey:(NSString *)key data:(NSData *)data;
- (NSArray *)queryDatabaseForkey:(NSString *)key;
-(void)removeFromDataBase:(NSString*)key;
-(NSArray *)getAllRows;

@end
