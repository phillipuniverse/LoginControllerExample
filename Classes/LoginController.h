//
//  LoginController.h
//  LoginControllerExample
//
//  Created by Phillip Verheyden on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	NotLoggedIn,
	LoggingIn,
	LoggedIn
} LoginState;

@interface LoginController : TTTableViewController <TTURLRequestDelegate, UITextFieldDelegate> {
	int _requestCount;
	LoginState _loginState;
	NSString *_requestURL;
	
	UITextField *_usernameField;
	UITextField *_passwordField;
	
	id<TTURLRequestDelegate> _delegate;
}

/*
 *	Current state of the login controller
 */
@property (nonatomic, readonly) LoginState loginState;

/**
 *	URL that the login controller uses
 */
@property (nonatomic, retain) NSString *requestURL;

/*
 *	Delegate that is called when the user is successfully authenticated
 */
@property (nonatomic, assign) id<TTURLRequestDelegate> delegate;

+(LoginController *) loginController;

/*
 *	Sends a request to the specified URL, checking the login and logging the user in if needed
 */
-(void) sendRequestWithURL:(NSString *)URL delegate:(id<TTURLRequestDelegate>)delegate;

@end
