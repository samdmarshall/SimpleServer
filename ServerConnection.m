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
	[self performSelectorOnMainThread:@selector(beginTimeoutCounter) withObject:nil waitUntilDone:YES];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
		client_listener = socket(AF_INET, SOCK_STREAM, 0);
		
		server_address.sin_family = AF_INET;
	    server_address.sin_addr.s_addr = INADDR_ANY;
	    server_address.sin_port = htons(port);
	
		bind(client_listener, (struct sockaddr*)&server_address, sizeof(server_address));
		listen(client_listener, 5);
		
		connection=accept(client_listener, NULL, NULL);
		is_active = (connection != -1 ? true : false);
				
		while (is_active) {
			// here we talk with the client.
		    int64_t random_data = 151691786587165;
		    size_t sent = send(connection, &random_data, sizeof(int64_t), 0);
		    size_t received = recv(connection, &random_data, sizeof(int64_t), 0);
		    is_active = ( (sent > 0 && received > 0) ? true : false);
		}
		close(client_listener);
		close(connection);
	});
}

- (void)sessionTimeOut:(NSTimer *)timer {
	@synchronized(self) {
		if (!is_active) {
			NSLog(@"session has ended");
			[self performSelectorOnMainThread:@selector(terminateConnection) withObject:nil waitUntilDone:YES];	
		}	
	}
}

- (void)terminateConnection {
	if (client_timeout != nil) {
		[client_timeout invalidate];
		[client_timeout release];
	}
	is_active = false;
	NSLog(@"connection has been ended");
}

- (void)beginTimeoutCounter {
	NSLog(@"creating time-out session timer.");
	client_timeout = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sessionTimeOut:) userInfo:nil repeats:YES];
}

- (void)dealloc {
	if (client_timeout != nil) {
		[client_timeout invalidate];
	}
	[client_timeout release];
	[super dealloc];
}

@end
