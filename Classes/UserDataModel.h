//
//  UserDataModel.h
//  LoginControllerExample
//
//  Created by Phillip Verheyden on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	Keeping track of when this model is loaded and not loaded is important when dealing
 *	with the login controller. Otherwise, your model states get kind of screwed up, since
 *	calling the login controller is asynchronous
 */
@interface UserDataModel : TTURLRequestModel {
	NSMutableArray	*_results;
	BOOL _loading;
	BOOL _loaded;	
}

@property (nonatomic, readonly) NSArray *results;

@end
