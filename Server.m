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
		listen(listener, 5);

		while (run_state) {
			connection=accept(listener, NULL, NULL);
			if (connection) {
				int16_t new_port = [self generateNewPort];
				write(connection, &new_port, sizeof(int16_t));
				ServerConnection *new_connection = [[ServerConnection alloc] initWithPort:new_port fromIP:connection];
				[new_connection activateConnection];
				[self addNewClientConnection:new_connection];
			}
			close(connection);
		}
		close(listener);
	});
}

- (NSString *)getServerIP {
	char host_buffer[200];
	gethostname(host_buffer, 200) ;
	struct hostent* local_host = (struct hostent*)gethostbyname(host_buffer);
	return [NSString stringWithCString:(inet_ntoa(*((struct in_addr *)local_host->h_addr))) encoding:NSASCIIStringEncoding];
}

- (int16_t)generateNewPort {
	int16_t a_port = ((double) rand() / (65535+1)) * (65535-49152+1) + 49152;
	for (ServerConnection *connected in active_connections) {
		if (connected.port == a_port)
			return [self generateNewPort];
	}
	return a_port;
}

- (void)addNewClientConnection:(ServerConnection *)connector {
	NSMutableArray *existing_connections = [[[NSMutableArray alloc] initWithArray:self.active_connections] autorelease];
	[existing_connections addObject:connector];
	[active_connections release];
	active_connections = [[NSArray alloc] initWithArray:existing_connections];
}

@end
