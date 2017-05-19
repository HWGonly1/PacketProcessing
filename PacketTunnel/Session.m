//
//  Session.m
//  PacketProcessing
//
//  Created by HWG on 2017/5/10.
//  Copyright © 2017年 HWG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@implementation Session

-(instancetype)init{
    return self;
}

-(void)trackAmountSentSinceLastAck:(int)amount{
    @synchronized (self.syncSendAmount) {
        _sendAmountSinceLastAck+=amount;
    }
}

-(void)decreaseAmountSentSinceLastack:(int)amount{
    @synchronized (self.syncSendAmount) {
        _sendAmountSinceLastAck-=amount;
        if(self.sendAmountSinceLastAck<0){
            _sendAmountSinceLastAck=0;
        }
    }
}






@end
