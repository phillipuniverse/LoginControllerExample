//
//  UserDataViewController.m
//  LoginControllerExample
//
//  Created by Phillip Verheyden on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserDataViewController.h"
#import "UserDataDataSource.h"
#import "UserDataModel.h"

@implementation UserDataViewController

- (void)viewDidLoad	{
	
}

- (void) createModel {
	UserDataDataSource *ds = [[UserDataDataSource alloc] init];
	ds.model = [[[UserDataModel alloc] init] autorelease];
	self.dataSource = ds;
	TT_RELEASE_SAFELY(ds);
}

@end
