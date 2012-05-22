//
//  ServerConnection.h
//  Server
//
//  Created by Sam Marshall on 5/21/12.
//  Copyright 2012 Sam Marshall. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>

@interface ServerConnection : NSObject {
	int32_t client_listener;
	int32_t connection;
	uint16_t port;
	struct sockaddr_in server_address;
	BOOL is_active;
	NSTimer *client_timeout;
}
@property (nonatomic, readonly) int32_t client_listener;
@property (nonatomic, readonly) int32_t connection;
@property (nonatomic, readonly) uint16_t port;
@property (nonatomic, readonly) struct sockaddr_in server_address;
@property (readonly) BOOL is_active;
@property (nonatomic, readonly) NSTimer *client_timeout;

- (id)initWithPort:(int16_t)port_num fromIP:(int32_t)client;
- (void)activateConnection;
- (void)terminateConnection;

@end
