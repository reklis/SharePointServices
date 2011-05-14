//
//  SPCredentials.m
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import "SPCredentials.h"


@implementation SPCredentials

@synthesize username;
@synthesize password;
@synthesize domain;

- (void)dealloc {
    [username release];
    [password release];
    [domain release];
    [super dealloc];
}

@end
