//
//  Plugin.m
//  iCloudKeyValue
//
//  Created by Gennadii Potapov on 30/7/16.
//  Add sync done callback Jonathan Leang
//  Copyright © 2016 General Arcade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCloudKV.h"
@implementation iCloudKV
bool isSynced = false;
iCloudKV *instance;

- (id)init {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self = [super init];
    //    if([[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]){
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyValueStoreChanged:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:[NSUbiquitousKeyValueStore defaultStore]];
    
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    //    }else{
    //        NSLog(@"iCloud is not enabled");
    //    }
    NSLog(@"iCloudKV - synchronize");
    return self;
}

-(void)keyValueStoreChanged:(NSNotification*)notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    isSynced = true;
//    NSNumber *reason = [[notification userInfo] objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
//
//    if (reason){
//        NSInteger reasonValue = [reason integerValue];
//        NSLog(@"keyValueStoreChanged with reason %ld", (long)reasonValue);
//
//        if (reasonValue == NSUbiquitousKeyValueStoreInitialSyncChange){
//            NSLog(@"Initial sync");
//        }else if (reasonValue == NSUbiquitousKeyValueStoreServerChange){
//            NSLog(@"Server change sync");
//        }else{
//            NSLog(@"Another reason");
//        }
//    }
}

@end


//I also like to include these two convenience methods to convert between c string and NSString*. You need to return a copy of the c string so that Unity handles the memory and gets a valid value.

char* cStringCopy(const char* string){
    if (string == NULL)
        return NULL;
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

// This takes a char* you get from Unity and converts it to an NSString* to use in your objective c code. You can mix c++ and objective c all in the same file.
static NSString* CreateNSString(const char* string){
    if (string != NULL)
        return [NSString stringWithUTF8String:string];
    else
        return [NSString stringWithUTF8String:""];
}

void iCloudKV_Init() {
    instance = [[iCloudKV alloc] init];
}

void iCloudKV_Synchronize() {
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

void iCloudKV_SetInt(char * key, int value) {
    [[NSUbiquitousKeyValueStore defaultStore] setObject:[NSNumber numberWithInt:value] forKey:[NSString stringWithUTF8String:key]];
    
}

void iCloudKV_SetFloat(char * key, float value) {
    [[NSUbiquitousKeyValueStore defaultStore] setObject:[NSNumber numberWithFloat:value] forKey:[NSString stringWithUTF8String:key]];
}

void iCloudKV_SetString(char * key, char * value) {
    [[NSUbiquitousKeyValueStore defaultStore] setString:[NSString stringWithUTF8String:value] forKey: [NSString stringWithUTF8String:key]];
}

int iCloudKV_GetInt(char * key) {
    NSNumber * num = (NSNumber *)([[NSUbiquitousKeyValueStore defaultStore] objectForKey:[NSString stringWithUTF8String:key]]);
    int i = 0;
    if (num != nil)
        i = [num intValue];
    return i;
}

float iCloudKV_GetFloat(char * key) {
    NSNumber * num = (NSNumber *)([[NSUbiquitousKeyValueStore defaultStore] objectForKey:[NSString stringWithUTF8String:key]]);
    float i = 0;
    if (num != nil)
        i = [num floatValue];
    return i;
}

char* iCloudKV_GetString(char * key) {
    NSString * text = (NSString *)([[NSUbiquitousKeyValueStore defaultStore] stringForKey:[NSString stringWithUTF8String:key]]);
    return cStringCopy([text UTF8String]);;
}

void iCloudKV_Reset() {
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    NSDictionary *kvd = [kvStore dictionaryRepresentation];
    NSArray *arr = [kvd allKeys];
    for (int i=0; i < arr.count; i++){
        NSString *key = [arr objectAtIndex:i];
        [kvStore removeObjectForKey:key];
    }
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

bool iCloudKV_isSynced(){
    return isSynced;
}

