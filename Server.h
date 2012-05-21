//
//  Server.h
//  Server
//
//  Created by Sam Marshall on 5/21/12.
//  Copyright 2012 Sam Marshall. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>
#import "DataStructs.h"


@interface Server : NSObject {
	int32_t listener;
	int32_t connection;
	int16_t port;
	struct sockaddr_in server_address;
	BOOL run_state;
}
@property (nonatomic, readonly) int32_t listener;
@property (nonatomic, readonly) int32_t connection;
@property (nonatomic, readonly) int16_t port;
@property (nonatomic, readonly) struct sockaddr_in server_address;
@property (readonly) BOOL run_state;

+ (Server *)sharedInstance;
- (id)init;
- (void)setPort:(int16_t)port_number;
- (void)setServerState:(BOOL)state;
- (void)runServer;
- (NSString *)getServerIP;

@end
