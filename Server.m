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
	}
	return self;
}

- (void)setPort:(int16_t)port_number {
	port = port_number;
}

- (void)setServerState:(BOOL)new_state {
	run_state = new_state;
}

- (void)runServer {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
		listener = socket(AF_INET, SOCK_STREAM, 0);
		
		server_address.sin_family = AF_INET;
	    server_address.sin_addr.s_addr = INADDR_ANY;
	    server_address.sin_port = htons(port);
	
		bind(listener, (struct sockaddr*)&server_address, sizeof(server_address));
		listen(listener, 1);

		while (run_state) {
			connection=accept(listener, NULL, NULL);
			if (connection) {
				char response[256];
				read(connection, response, 256);
				write(connection, "world!\n", 8);
			}
		}
		close(listener);
		close(connection);
	});
}

- (NSString *)getServerIP {
	char host_buffer[200];
	gethostname(host_buffer, 200) ;
	struct hostent* local_host = (struct hostent*)gethostbyname(host_buffer);
	return [NSString stringWithCString:(inet_ntoa(*((struct in_addr *)local_host->h_addr))) encoding:NSASCIIStringEncoding];
}

@end
