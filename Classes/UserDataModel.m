//
//  UserDataModel.m
//  LoginControllerExample
//
//  Created by Phillip Verheyden on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserDataModel.h"
#import "LoginController.h"
#import "GDataXMLNode.h"

@implementation UserDataModel

#pragma mark NSObject
- (id)init {
	if (self = [super init]) {
		_results = [[NSMutableArray alloc] init];
		_loading = NO;
		_loaded = NO;	
	}
	
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_results);
	
	[super dealloc];
}

#pragma mark TTModel
-(BOOL) isLoading{
	return _loading;
}

-(BOOL) isLoaded{
	return !_loading && _loaded;
}

#pragma mark TTURLRequestModel
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	_loading = YES;
	
	[[LoginController loginController] sendRequestWithURL:@"http://phillipuniverse.com/testLoginFail.xml" delegate:self];
}

/**
 *	Called by the logincontroller on successful login with the data from the queried URL.
 *	Should parse the results here just like you would if it wasn't going through the login controller
 */
- (void)requestDidFinishLoad:(TTURLRequest *)request {
	_loading = NO;
	_loaded = YES;

	[super requestDidFinishLoad:request];
}

/*
 *	Called by the login controller when it failed logging in
 */
- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	//you don't really have to do anything in here since this will just
	//pass up the chain and ultimate show the error view but you can if you want
	
	[super request:request didFailLoadWithError:error];
}

- (NSArray *)results {
	return [[_results copy] autorelease];
}

@end
