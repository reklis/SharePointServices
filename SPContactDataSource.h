//
//  SPContactDataSource.h
//  SharePointClient
//
//  Created by Steven Fusco on 3/9/11.
//  Copyright 2011 Cibo Technology, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SharePointServices.h"
#import "SPDataSource.h"

@class SPContact;

@interface SPContactDataSource : SPDataSource
{
@private
    SPList* list;
}

@property (readwrite,retain) NSDictionary* contacts;
@property (readwrite,retain) NSArray* contactIndexes;

- (void) loadContactsListNamed:(NSString*)listName;
- (SPContact*) itemAtPath:(NSIndexPath*)indexPath;

@end


@interface SPContact : NSObject <NSCoding>
{
}

@property (readwrite,nonatomic,retain) NSString* lastName;
@property (readwrite,nonatomic,retain) NSString* firstName;
@property (readwrite,nonatomic,retain) NSString* email;
@property (readwrite,nonatomic,retain) NSString* jobTitle;
@property (readwrite,nonatomic,retain) NSString* workPhone;
@property (readwrite,nonatomic,retain) NSString* mobilePhone;

- (NSString*) formattedName;

@end