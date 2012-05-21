//
//  ServerViewController.h
//
//  Created by Sam Marshall on 5/21/12.
//  Copyright 2012 Sam Marshall. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Server.h"

@interface ServerViewController : NSObject {
    IBOutlet id IPAddress;
    IBOutlet id PortNumber;
    IBOutlet id ServerButton;

	BOOL server_state;
}
@property (nonatomic, retain) NSButton *ServerButton;
@property (nonatomic, readonly) BOOL server_state;
@property (nonatomic, retain) NSTextField *PortNumber;
@property (nonatomic, retain) NSTextField *IPAddress;

- (void)setServerButtonAction;
- (IBAction)runServer:(id)sender;
- (IBAction)stopServer:(id)sender;
@end
