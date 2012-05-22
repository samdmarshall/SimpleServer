//
//  ServerConnection.m
//  Server
//
//  Created by Sam Marshall on 5/21/12.
//  Copyright 2012 Sam Marshall. All rights reserved.
//

#import "ServerConnection.h"


@implementation ServerConnection

@synthesize client_listener;
@synthesize connection;
@synthesize port;
@synthesize server_address;
@synthesize is_active;
@synthesize client_timeout;

- (id)initWithPort:(int16_t)port_num fromIP:(int32_t)client {
	self = [super init];
	if (self) {
		client_listener = 0;
		connection = 0;
		port = port_num;
		memset(&server_address, 0, sizeof(server_address));
		is_active = false;	
	}
	return self;
}

- (void)activateConnection {
	is_active = true;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
		client_listener = socket(AF_INET, SOCK_STREAM, 0);
		
		server_address.sin_family = AF_INET;
	    server_address.sin_addr.s_addr = INADDR_ANY;
	    server_address.sin_port = htons(port);
	
		bind(client_listener, (struct sockaddr*)&server_address, sizeof(server_address));
		listen(client_listener, 1);

		while (is_active) {
			connection=accept(client_listener, NULL, NULL);
			if (connection) {
				[self beginTimeoutCounter];
				// here we talk with the client.
				[self resetTimeoutCounter];
			}
		}
		close(client_listener);
		close(connection);
	});
}

- (void)terminateConnection {
	is_active = false;
}

- (void)beginTimeoutCounter {
	client_timeout = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(terminateConnection) userInfo:nil repeats:NO];
}

- (void)resetTimeoutCounter {
	if (client_timeout != nil) {
		[client_timeout invalidate];
		[client_timeout release];
	}		
	[self beginTimeoutCounter];
}

- (void)dealloc {
	if (client_timeout != nil) {
		[client_timeout invalidate];
	}
	[client_timeout release];
	[super dealloc];
}

@end
