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
#ifndef CONFIGURATION_WebServer		
	[self performSelectorOnMainThread:@selector(beginTimeoutCounter) withObject:nil waitUntilDone:YES];
#endif
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
		client_listener = socket(AF_INET, SOCK_STREAM, 0);
		
		server_address.sin_family = AF_INET;
	    server_address.sin_addr.s_addr = INADDR_ANY;
	    server_address.sin_port = htons(port);
	
		bind(client_listener, (struct sockaddr*)&server_address, sizeof(server_address));
		listen(client_listener, 1);
		
#ifndef CONFIGURATION_WebServer		
		connection=accept(client_listener, NULL, NULL);
		bool data_session = (connection != -1 ? true : false);

		while (data_session) {
			// here we talk with the client.
		    int64_t random_data = 151691786587165;
		    size_t sent = send(connection, &random_data, sizeof(int64_t), 0);
		    size_t received = recv(connection, &random_data, sizeof(int64_t), 0);
		    data_session = ( (sent > 0 && received > 0) ? true : false);
		}
		close(connection);
#else
		while (is_active) {
			connection=accept(client_listener, NULL, NULL);
			bool http_session = (connection != -1 ? true : false);
			if (http_session) {
				char *http_page = "HTTP/1.1 200 OK\nDate: Thu, 7 June 2012 12:00:00 GMT\nServer: Apache/x.x.x\nLast-Modified: Thur, 7 June 2012 12:00:00 GMT\nETag: \"xxx-#######-####x###\"\nContent-Type: text/html\nContent-Length: 345\nAccept-Ranges: bytes\nConnection: close\n\n<html><head><title>example server</title></head><body>example web server using c sockets</body></html>";
				write(connection, http_page, strlen(http_page));
			}
			close(connection);
		}
#endif
		close(client_listener);
#ifndef CONFIGURATION_WebServer
		[self performSelectorOnMainThread:@selector(terminateConnection) withObject:nil waitUntilDone:YES];
#endif
	});
}

- (void)sessionTimeOut:(NSTimer *)timer {
	NSLog(@"The session has timed-out.");
	[self performSelectorOnMainThread:@selector(terminateConnection) withObject:nil waitUntilDone:YES];
}

- (void)terminateConnection {
	if (is_active) {
		if ([client_timeout isValid])
			[client_timeout invalidate];
		is_active = false;
		NSLog(@"The connection has been ended.");
	}
}

- (void)beginTimeoutCounter {
	NSLog(@"Creating new session...");
	client_timeout = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sessionTimeOut:) userInfo:nil repeats:YES];
}

- (void)dealloc {
	[client_timeout release];
	[super dealloc];
}

@end
