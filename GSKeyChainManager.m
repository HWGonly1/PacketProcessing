//
//  GSKeyChainManager.m
//  PacketProcessing
//
//  Created by HWG on 2017/6/23.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSKeyChainManager.h"
#import "GSKeyChain.h"

@implementation GSKeyChainManager

static NSString* const KEY_IN_KEYCHAIN_UUID=@"MagentUUID";
static NSString* const KEY_UUID=@"magentUUID";

+(void)saveUUID:(NSString *)UUID{
    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
    [usernamepasswordKVPairs setObject:UUID forKey:KEY_UUID];
    
    [GSKeyChain save:KEY_IN_KEYCHAIN_UUID data:usernamepasswordKVPairs];
}

+(NSString *)readUUID{
    
    NSMutableDictionary *usernamepasswordKVPair = (NSMutableDictionary *)[GSKeyChain load:KEY_IN_KEYCHAIN_UUID];
    
    return [usernamepasswordKVPair objectForKey:KEY_UUID];
    
}

+(void)deleteUUID{
    
    [GSKeyChain delete:KEY_IN_KEYCHAIN_UUID];
    
}

@end
