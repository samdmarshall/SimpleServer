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
#import "ServerConnection.h"

@interface Server : NSObject {
	int32_t listener;
	int32_t connection;
	uint16_t port;
	struct sockaddr_in server_address;
	BOOL run_state;
	NSArray *active_connections;
}
@property (nonatomic, readonly) int32_t listener;
@property (nonatomic, readonly) int32_t connection;
@property (nonatomic, readonly) uint16_t port;
@property (nonatomic, readonly) struct sockaddr_in server_address;
@property (readonly) BOOL run_state;
@property (nonatomic, readonly) NSArray *active_connections;

+ (Server *)sharedInstance;
- (id)init;
- (void)setPort:(uint16_t)port_number;
- (void)setServerState:(BOOL)state;
- (void)runServer;
- (NSString *)getServerIP;
- (uint16_t)generateNewPort;
- (void)addNewClientConnection:(ServerConnection *)connector;
- (void)disconnectTimedOutSessions;
- (void)terminateExistingConnections;

@end
