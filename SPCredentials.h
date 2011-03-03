//
//  SPCredentials.h
//  SharePointClient
//
//  Created by Steven Fusco on 2/27/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SPCredentials : NSObject {

}

@property (readwrite,nonatomic,retain) NSString* username;
@property (readwrite,nonatomic,retain) NSString* password;
@property (readwrite,nonatomic,retain) NSString* domain;

@end
