//
//  ServerViewController.m
//
//  Created by Sam Marshall on 5/21/12.
//  Copyright 2012 Sam Marshall. All rights reserved.
//

#import "ServerViewController.h"

@implementation ServerViewController

@synthesize IPAddress;
@synthesize PortNumber;
@synthesize ServerButton;
@synthesize server_state;

- (void)awakeFromNib {
	server_state = false;
	[self setServerButtonAction];
	[ServerButton setTarget:self];
	[IPAddress setStringValue:[[Server sharedInstance] getServerIP]];
	[PortNumber setStringValue:[NSString stringWithFormat:@"%i",[Server sharedInstance].port]];
}

- (void)setServerButtonAction {
	(server_state ? [ServerButton setAction:@selector(stopServer:)] : [ServerButton setAction:@selector(runServer:)]);
}

- (IBAction)runServer:(id)sender {
	server_state = true;
	[ServerButton setTitle:@"Stop Server"];
	[self setServerButtonAction];
	[[Server sharedInstance] setPort:[[PortNumber stringValue] intValue]];
	[[Server sharedInstance] setServerState:server_state];
	[[Server sharedInstance] runServer];
}

- (IBAction)stopServer:(id)sender {
    server_state = false;
	[ServerButton setTitle:@"Start Server"];
	[self setServerButtonAction];
	[[Server sharedInstance] setServerState:server_state];
}

- (void)dealloc {
	[ServerButton release];
	[IPAddress release];
	[PortNumber release];
	[super dealloc];
}

@end
