//
//  DBManager.m
//  KVPStore
//
//  Created by Kaustubh on 30/09/15.
//  Copyright (c) 2015 VW. All rights reserved.
//

#import "DBManager.h"
#import "Constants.h"
#define kTableName @"KeyValueTable"

@interface DBManager()
{
    //sqlite3 *db;
}
@property (nonatomic, retain) NSString *file;

@end

@implementation DBManager

static DBManager *sharedInstance;


+(instancetype)shareInstance
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^
    {
        if (!sharedInstance)
        {
            sharedInstance = [[super allocWithZone:NULL]init];
            //[sharedInstance createDatabase];
            sharedInstance.file=[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], kDatabaseName];
            [sharedInstance createKeyValueTable];
            [sharedInstance ensureTableExists];
            sharedInstance.file=[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], kDatabaseName];
        }
    });
    return sharedInstance;
}

-(void)createDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Database filename can have extension db/sqlite.
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbName=kDatabaseName;
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:dbName];
    success = [fileManager fileExistsAtPath:dbPath];
    if (success)
    {
        return;
    }
    NSString *defaultDBPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:dbName];
    success = [fileManager fileExistsAtPath:defaultDBPath];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
    if (!success)
    {
        NSException *exception=[NSException exceptionWithName:@"SQLError" reason:@"Unable to create database" userInfo:nil];
        @throw exception;
    }
}

-(void)createKeyValueTable
{
    [self queryDatabaseWithStatement:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (key TEXT PRIMARY KEY, VALUE BLOB)", kTableName]];
}

-(void)ensureTableExists
{
    NSString *statement = @"select name from sqlite_master where type='table' ORDER BY name;";
    [self queryDatabaseWithStatement:statement];
}

-(sqlite3 *)openDatabase
{
    sqlite3 *dataBase=nil;
    const char *databasePath=[self.file UTF8String];
    int result=sqlite3_open(databasePath, &dataBase);
    if (result!=SQLITE_OK)
    {
        NSException *exception=[NSException exceptionWithName:@"SQLError" reason:@"Unable to open SQL database" userInfo:nil];
        @throw exception;
    }
    return dataBase;
}

- (void)closeDatabase:(sqlite3 *)db
{
    sqlite3_close(db);
}

-(void)queryDatabaseWithStatement:(NSString*)statement
{
    sqlite3 *db=[self openDatabase];
    sqlite3_threadsafe();
    const char *tailStatement;
    const char *sqlStatement=[statement UTF8String];
    sqlite3_stmt *stmt;
    if ((sqlite3_prepare_v2(db, sqlStatement, -1, &stmt, &tailStatement) != SQLITE_OK))
    {
        return;
    }
    
    char * errInfo ;
    int x=sqlite3_exec(db, sqlStatement, NULL, NULL, &errInfo);
    if (x==SQLITE_OK) {
        NSLog(@"Table created");
    }
    else
    {
        NSLog(@"%d", x);
    }
    NSLog(@"%s", sqlite3_errmsg(db));
    //sqlite3_finalize(stmt);
    sqlite3_close(db);
}

-(void)removeFromDataBase:(NSString*)key
{
    NSString *statement=[NSString stringWithFormat:@"delete from %@ where key= ?", kTableName];
    sqlite3 *db=[self openDatabase];
    [self queryDatabase:db statement:statement key:key];
}

-(NSArray *)getAllRows
{
    NSArray *restultArr;
    NSString *statement=[NSString stringWithFormat:@"SELECT key, value FROM %@", kTableName];
    sqlite3 *db=[self openDatabase];
    restultArr=[self queryDatabase:db statement:statement key:nil];
    return restultArr;
}

- (NSArray *)queryDatabase:(sqlite3 *)db statement:(NSString *)statement key:(NSString *)key
{
    NSMutableArray *resultArray;
    const char *tailStatement;
    const char *sqlStatement=[statement UTF8String];
    sqlite3_stmt *stmt;
    
    if ((sqlite3_prepare_v2(db, sqlStatement, -1, &stmt, &tailStatement) != SQLITE_OK))
    {
        return nil;
    }
    
    if (key)
    {
        sqlite3_bind_text(stmt, 1, [key UTF8String], -1, SQLITE_STATIC);
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW)
    {
        if (resultArray == nil)
        {
            resultArray=[NSMutableArray array];
        }
        const char *keyFromDB=(const char *)sqlite3_column_text(stmt, 0);
        if (keyFromDB!=nil)
        {
            NSString *key = [NSString stringWithCString:keyFromDB encoding:NSUTF8StringEncoding];
            NSData *blob = [NSData dataWithBytes:sqlite3_column_blob(stmt, 1) length:sqlite3_column_bytes(stmt, 1)];
            NSMutableDictionary *rowDict = [NSMutableDictionary dictionaryWithObject:key forKey:@"key"];
            if ([blob length])
            {
                id value = [self unarchiveData:blob];
                [rowDict setObject:value forKey:@"value"];
            }
            [resultArray addObject:rowDict];
        }
    }
    
    sqlite3_finalize(stmt);
    return resultArray;
}
- (NSArray *)queryDatabaseForkey:(NSString *)key
{
    NSString *statement=[NSString stringWithFormat:@"select key, value from %@ where key= ?", kTableName];
    sqlite3 *db=[self openDatabase];
    NSMutableArray *arr=[self queryDatabase:db statement:statement key:key];
    return arr;
}

- (id)unarchiveData:(NSData *)data
{
    id unArchivedData=nil;
    if (data != nil)
        unArchivedData=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return unArchivedData;
}

- (void)queryDatabaseWithkey:(NSString *)key data:(NSData *)data
{
    NSString *statement=[NSString stringWithFormat:@"insert or replace into %@ (key,value) values ( ?, ?); commit;",
                         kTableName];
    sqlite3 *db=[self openDatabase];
    const char *sql = [statement UTF8String];
    sqlite3_stmt *stmt;
    NSError  *error=nil;
    if ((sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK))
    {
        sqlite3_bind_text(stmt, 1, [key UTF8String], -1, SQLITE_STATIC);
        sqlite3_bind_blob(stmt, 2, [data bytes], (int)[data length], SQLITE_STATIC);
    }
    NSLog(@"%s", sqlite3_errmsg(db));
    
    int status = sqlite3_step(stmt);
    if (status != SQLITE_DONE)
    {
        const char *errMsg = sqlite3_errmsg(db);
        NSString *errorMsg = [[NSString alloc] initWithUTF8String:errMsg];
        error=[NSError errorWithDomain:@"kvpstoreerror" code:1 userInfo:[NSDictionary dictionaryWithObject:errorMsg forKey:@"message"]];
        NSLog(@"%s", sqlite3_errmsg(db));
    }
    sqlite3_finalize(stmt);
    [self closeDatabase:db];
}

@end
