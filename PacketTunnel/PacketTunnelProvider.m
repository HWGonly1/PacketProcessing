//
//  PacketTunnelProvider.m
//  PacketTunnel
//
//  Created by HWG on 2017/4/25.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import "TunnelInterface.h"
#import "PacketUtil.h"
#import "SessionManager.h"
#import "Message.h"
@import NetworkExtension;

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
    //[[Message shareInstance] startLoop];
    [self appendStrategy:@""];
    [SessionManager setupWithPacketTunnelFlow:self.packetFlow];
    NEIPv4Settings *ipv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[[PacketUtil getLocalIpAddress]] subnetMasks:@[@"255.255.255.0"]];
    ipv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"127.0.0.1"];
    settings.IPv4Settings = ipv4Settings;
    settings.MTU = [NSNumber numberWithInt:1600];
    settings.DNSSettings=[[NEDNSSettings alloc] initWithServers:@[@"8.8.8.8",@"219.141.136.10"]];
    [self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
        if (error) {
            if (completionHandler) {
                completionHandler(error);
            }
        }else{
            if (completionHandler) {
                completionHandler(nil);
            }
        }
    }];
    [TunnelInterface setPacketFlow:self.packetFlow];
    
    [TunnelInterface processPackets];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
    // Add code here to start the process of stopping the tunnel
    [TunnelInterface sharedInterface].processing=false;
    for(NSString* key in [SessionManager sharedInstance].tcpdict.allKeys){
        TCPSession* session=[[SessionManager sharedInstance].tcpdict objectForKey:key];
        [[SessionManager sharedInstance]closeSession:session];
    }
    for(NSString* key in [SessionManager sharedInstance].udpdict.allKeys){
        UDPSession* session=[[SessionManager sharedInstance].udpdict objectForKey:key];
        [[SessionManager sharedInstance]closeUDPSession:session];
    }
    completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler
{
    // Add code here to handle the message
    if (completionHandler != nil) {
        completionHandler(messageData);
    }
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler
{
    // Add code here to get ready to sleep
    completionHandler();
}

- (void)wake
{
    // Add code here to wake up
}

-(void)appendStrategy:(NSString*)strategy{
    @autoreleasepool {
        
        NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *homePath = [paths objectAtIndex:0];
        NSString *filePath = [homePath stringByAppendingPathComponent:@"Strategy.txt"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSLog(@"FileExists");
        }
        else {
            NSLog(@"FileNotExists");
            [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        
        
        NSFileHandle* fhw=[NSFileHandle fileHandleForWritingAtPath:filePath];//以只写的方式打开指定位置的文件，创建文件句柄//当我们以只写形式打开一个文件的时候，文件的内容全都在，并未被清空，我们写入的内容会直接覆盖原内容（与C语言不同）
        //[fh writeData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding]];//以NSData的形式写入//以C语言文件控制-w方式写入（清空再写入）
        //[fh truncateFileAtOffset:0];//将文件内容截短至0字节(清空)
        //[fh writeData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding]];//这样就相当于按-w方式写入//以C语言文件控制-a方式写入（保持原来文件内容不变，向后追加）
        [fhw seekToEndOfFile];//将读写指针设置在文件末尾
        [fhw writeData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding]];//这样就相当于按-a方式写入
        //[strategy writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [fhw closeFile];
        
        if ([fileManager fileExistsAtPath:filePath]) {
            NSLog(@"FileExists");
        }
        else {
            NSLog(@"FileNotExists");
        }
        
        
        //创建文件句柄
        NSFileHandle* fhr=[NSFileHandle fileHandleForReadingAtPath:filePath];
        //以只读的方式打开指定位置的文件，创建文件句柄 //读
        //NSData* data=[fh readDataOfLength:3];//对里面内容读3个字节,以NSData形式输出
        //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);//转换成字符串输出//连续使用readDataofLength方法，会接着上次读取的进度继续读文件下面的内容：
        //NSData* data=[fh readDataOfLength:3];//先读前三个字节
        //NSData* data=[fh readDataOfLength:5];//由于文件读指针发生偏移，从第四个字节开始读后面五个字节
        //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);//如果文件内容不是很多，可直接一次性阅读至文件结尾。
        NSData* data=[fhr readDataToEndOfFile];
        [fhr closeFile];
        NSLog(@"%@%@",@"FileString:",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
}
@end



























