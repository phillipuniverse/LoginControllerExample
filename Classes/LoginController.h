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
    id _originalUserInfo;
    NSDictionary *_originalParameters;
}

/**
 *	Current state of the login controller
 */
@property (nonatomic, readonly) LoginState loginState;

/**
 *	URL that the login controller uses
 */
@property (nonatomic, retain) NSString *requestURL;

/**
 *	Delegate that is called when the user is successfully authenticated
 */
@property (nonatomic, assign) id<TTURLRequestDelegate> delegate;

+ (LoginController *)loginController;

/**
 *	Sends a request to the specified URL, checking the login and logging the user in if needed
 */
- (void)sendRequestWithURL:(NSString *)URL delegate:(id<TTURLRequestDelegate>)delegate;
- (void)sendRequestWithURL:(NSString *)URL delegate:(id<TTURLRequestDelegate>)delegate userInfo:(id)userInfo;
/**
 *  If parameters is not nil, then the request type is POST. Otherwise, it's a GET
 */
- (void)sendRequestWithURL:(NSString *)URL delegate:(id<TTURLRequestDelegate>)delegate userInfo:(id)userInfo parameters:(NSDictionary *)parameters;

/**
 *	Logs in via sessions/cookies ONLY if it's not already logged in. This sends a maximum of 1 extra request to the server.
 *	If the controller can't log in itself, it pops up the login controller.  Calls requestDidFinishLoad or request:didFailLoadWithError
 *	on the delegate depending on the result of the attempted login.
 */
- (void)loginWithDelegate:(id<TTURLRequestDelegate>)delegate;

@end
