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
		listener = socket(AF_INET, SOCK_STREAM, 0);
		
		server_address.sin_family = AF_INET;
	    server_address.sin_addr.s_addr = INADDR_ANY;
	    server_address.sin_port = htons(port);
	
		bind(listener, (struct sockaddr*)&server_address, sizeof(server_address));
		listen(listener, 5);

		while (run_state) {
			connection=accept(listener, NULL, NULL);
			if (connection) {
				// here we talk with the client.
			}
		}
		close(listener);
		close(connection);
	});
}

@end
