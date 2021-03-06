//
//  Server.m
//  Server
//
//  Created by Sam Marshall on 5/21/12.
//  Copyright 2012 Sam Marshall. All rights reserved.
//

#import "Server.h"


@implementation Server

@synthesize listener;
@synthesize connection;
@synthesize port;
@synthesize server_address;
@synthesize run_state;
@synthesize active_connections;

static Server *sharedInstance = nil;

+ (Server *)sharedInstance {
	static dispatch_once_t pred;
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (id)init {
	self = [super init];
	if (self) {
		listener = 0;
		connection = 0;
		port = 1234; //default port
		memset(&server_address, 0, sizeof(server_address));
		run_state = false;
		active_connections = [[NSArray alloc] init];
	}
	return self;
}

- (void)setPort:(uint16_t)port_number {
	port = port_number;
}

- (void)setServerState:(BOOL)new_state {
	run_state = new_state;
	if (!run_state)
		[self terminateExistingConnections];
}

- (void)runServer {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
		listener = socket(AF_INET, SOCK_STREAM, 0);
		
		server_address.sin_family = AF_INET;
	    server_address.sin_addr.s_addr = INADDR_ANY;
	    server_address.sin_port = htons(port);
	
		bind(listener, (struct sockaddr*)&server_address, sizeof(server_address));
		listen(listener, 5);

		while (run_state) {
			[self disconnectTimedOutSessions];
			// we accept a connection, then generate a new port for it to use. 
			// once the port number is generated, we send that number back to the client and then create a new session on that port.
			// we then terminate the client connection on the master port and wait for the client to connect on the new port given.
			connection=accept(listener, NULL, NULL);
			if (connection) {
				uint16_t new_port = [self generateNewPort];
				uint16_t result = 0;
#ifndef CONFIGURATION_WebServer
				new_port = htons(new_port);
				send(connection, &new_port, sizeof(new_port), 0);
				recv(connection, &result, sizeof(uint16_t), 0);
				result = ntohs(result);
				// code 1000 == OK
				// code 500 == bad port recieved - abort
				if (result == 1000) {
					ServerConnection *new_connection = [[ServerConnection alloc] initWithPort:ntohs(new_port) fromIP:connection];
					[self performSelectorOnMainThread:@selector(addNewClientConnection:) withObject:new_connection waitUntilDone:YES];
				}
				// check against something, internal blacklist for IP then return respective code response.
				result = htons(result);
				send(connection, &result, sizeof(uint16_t), 0);
#else
				ServerConnection *new_connection = [[ServerConnection alloc] initWithPort:new_port fromIP:connection];
				[self performSelectorOnMainThread:@selector(addNewClientConnection:) withObject:new_connection waitUntilDone:YES];
				char *buffer;
				char *http_redirect = [[NSString stringWithFormat:@"HTTP/1.1 200 OK\nDate: Thu, 7 June 2012 12:00:00 GMT\nServer: Apache/x.x.x\nLast-Modified: Thur, 7 June 2012 12:00:00 GMT\nETag: \"xxx-#######-####x###\"\nContent-Type: text/html\nContent-Length: %i\nAccept-Ranges: bytes\nConnection: close\n\n<HTML><HEAD><META HTTP-EQUIV=\"refresh\" CONTENT=\"1;URL=http://%@:%i\"></HEAD><body></body></html>",[[self getServerIP] length]+343,[self getServerIP],new_port] cStringUsingEncoding:NSASCIIStringEncoding];
				write(connection, http_redirect, strlen(http_redirect));
				read(connection, buffer, 255);
#endif
			}
			close(connection);
		}
		close(listener);
	});
}

- (NSString *)getServerIP {
	char host_buffer[512];
	gethostname(host_buffer, 512);
	struct hostent* local_host = (struct hostent*)gethostbyname(host_buffer);
	return [NSString stringWithCString:(inet_ntoa(*((struct in_addr *)local_host->h_addr))) encoding:NSASCIIStringEncoding];
}

- (uint16_t)generateNewPort {
	uint16_t a_port = (rand()%(65535-49152))+49152;
	NSArray *connection_iterate = [[[NSArray alloc] initWithArray:active_connections] autorelease];
	for (ServerConnection *connected in connection_iterate) {
		if ((connected.port == a_port && connected.is_active) || (port == a_port))
			return [self generateNewPort];
	}
	return a_port;
}

- (void)addNewClientConnection:(ServerConnection *)connector {
	NSMutableArray *existing_connections = [[[NSMutableArray alloc] initWithArray:active_connections] autorelease];
	[active_connections release];
	[connector activateConnection];
	[existing_connections addObject:connector];
	active_connections = [[NSArray alloc] initWithArray:existing_connections];
}

- (void)disconnectTimedOutSessions {
	NSMutableArray *existing_connections = [[[NSMutableArray alloc] initWithArray:active_connections] autorelease];
	NSArray *connection_iterate = [[[NSArray alloc] initWithArray:active_connections] autorelease];
	for (ServerConnection *connected in connection_iterate) {
		if (!connected.is_active)
			[existing_connections removeObject:connected];
	}
	[active_connections release];
	active_connections = [[NSArray alloc] initWithArray:existing_connections];
}

- (void)terminateExistingConnections {
	for (ServerConnection *connected in active_connections) {
		[connected performSelectorOnMainThread:@selector(terminateConnection) withObject:nil waitUntilDone:YES];
	}
	[self disconnectTimedOutSessions];
}

@end