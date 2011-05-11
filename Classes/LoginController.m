//
//  LoginController.m
//  LoginControllerExample
//
//  Created by Phillip Verheyden on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "GDataXMLNode.h"

#define LOGIN_SUCCESS 1
#define LOGIN_FAIL 0

static LoginController *gLoginController = nil;

@interface LoginController ()
-(void) submitLoginForm;
-(void) cancelLoginForm;
-(NSArray *) tableItems;
-(void) failedLogin;
-(void) successfulLoginWithRequest:(TTURLRequest*)request;
@end

@implementation LoginController

@synthesize delegate = _delegate;
@synthesize loginState = _loginState;
@synthesize requestURL = _requestURL;

+(LoginController *) loginController{
	if(!gLoginController){
		TTDPRINT(@"Initializing the login controller");
		gLoginController = [[LoginController alloc] init];
	}
	
	return gLoginController;
}

-(id) init {
	if(self = [super init]){
		_requestCount = 0;
		_loginState = NotLoggedIn;
		
		_usernameField = [[UITextField alloc] init];
		_usernameField.placeholder = @"Username";
		_usernameField.clearButtonMode = UITextFieldViewModeAlways;
		_usernameField.returnKeyType = UIReturnKeyNext;
		_usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
		_usernameField.text = @"";
		_usernameField.delegate = self;
		
		_passwordField = [[UITextField alloc] init];
		_passwordField.placeholder = @"Password";
		_passwordField.clearButtonMode = UITextFieldViewModeAlways;
		_passwordField.returnKeyType = UIReturnKeyGo;
		_passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
		_passwordField.secureTextEntry = YES;
		_passwordField.text = @"";
		_passwordField.delegate = self;
		
		self.tableViewStyle = UITableViewStyleGrouped;
	}
	
	return self;
}

-(void) dealloc {
	_delegate = nil;
	gLoginController = nil;
	self.requestURL = nil;
	[super dealloc];
}

/**
 *	Overwrote this to actually return the shared instance of the LoginController and NOT a new instance which will be created
 */
-(id) initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
	TTDPRINT(@"Returning the shared controller");
	return [[self class] loginController];
}

#pragma mark -
#pragma mark Send/Parse Request
-(void) sendRequestWithURL:(NSString *)URL delegate:(id<TTURLRequestDelegate>)delegate{
	_delegate = delegate;
	self.requestURL = URL;
	
	TTDPRINT(@"Going to user URL: %@", URL);
	TTURLRequest *request = [TTURLRequest requestWithURL:URL delegate:self];
	request.cachePolicy = TTURLRequestCachePolicyNone;
	request.response = [[TTURLDataResponse alloc] init];
	request.httpMethod = @"GET";
	
	[request send];
}

-(void) requestDidFinishLoad:(TTURLRequest*)request{
	TTURLDataResponse *response = request.response;
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:response.data 
														   options:0 error:nil];
	NSString *responseBody = [[NSString	alloc] initWithData:response.data encoding:NSASCIIStringEncoding];
	TTDPRINT(@"Logincontroller response: %@", responseBody);
	
	int loginStatus = [[(GDataXMLElement *)[[doc.rootElement elementsForName:@"login_status"] objectAtIndex:0] stringValue] intValue];
	TTDPRINT(@"Login status: %i", loginStatus);
	switch (loginStatus) {
		case LOGIN_SUCCESS:
			[self successfulLoginWithRequest:request];
			break;
		case LOGIN_FAIL:
			[self failedLogin];
			break;
		default:
			break;
	}
	
	TT_RELEASE_SAFELY(responseBody);
	TT_RELEASE_SAFELY(doc);
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	TTDPRINT(@"Textfield done editing with: ");
	if(textField == _usernameField) {
		[_passwordField becomeFirstResponder];
	}
	else if(textField == _passwordField) {
		[textField resignFirstResponder];
		[self submitLoginForm];
	}
	return NO;
}

#pragma mark -
#pragma mark Private Methods
/**
 *	Tries to load from NSUserDefaults if the cookies aren't set (automatic) before showing the login form
 */
- (void)failedLogin {
	TTDPRINT(@"Not logged in, showing the login form");
	if(_requestCount == 0) {
		//First try to resend with the username/password from NSUserDefaults if they are set
		if([[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] length] && [[[NSUserDefaults standardUserDefaults] stringForKey:@"password"] length]) {
			TTDPRINT(@"Using the saved username/password in NSUserDefaults");
			_usernameField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
			_passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
			[self submitLoginForm];
		}
		else {
			[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://loginForm"] applyAnimated:YES]];
		}
	}
	else {
		//I've already tried this once, so the login form must have been submitted.  Therefore, show an alert and re-enable the 
		//username/password fields
		TTAlertNoTitle(@"Invalid username or password");
		_loginState = NotLoggedIn;
		TTDPRINT(@"Username text: %@", _usernameField.text);
		TTDPRINT(@"Password text: %@", _passwordField.text);
		[_usernameField becomeFirstResponder];
		[self createModel];
		[self reload];
	}
}

/**
 *	Save the cookies, username and password in NSUserDefaults and then call the delegate requestDidFinishLoad
 */
- (void)successfulLoginWithRequest:(TTURLRequest*)request {
	TTDPRINT(@"I'm logged in! Hooray!");
	
	for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		TTDPRINT(@"Cookie name: %@, value: %@", cookie.name, cookie.value);
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]] forKey:@"cookies"];
	[[NSUserDefaults standardUserDefaults] setObject:_usernameField.text forKey:@"username"];
	[[NSUserDefaults standardUserDefaults] setObject:_passwordField.text forKey:@"password"];
	_loginState = LoggedIn;	
	
	[[[TTNavigator navigator] visibleViewController] dismissModalViewController];
	[_delegate requestDidFinishLoad:request];
	_delegate = nil;
	self.requestURL = nil;
}

/*
 *	Submits the username and password to the server
 */
-(void) submitLoginForm {
	_loginState = LoggingIn;
	_requestCount++;
	//make sure to reload the tableview to display the TTActivityIndicatorItem
	[self createModel];
	[self reload];
	
	TTURLRequest *request = [TTURLRequest requestWithURL:_requestURL delegate:self];
	//Don't use a cache because it can be pretty dynamic content
	request.cachePolicy = TTURLRequestCachePolicyNone;
	request.response = [[TTURLDataResponse alloc] init];
	request.httpMethod = @"POST";
	[request.parameters setObject:[_usernameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"username"];
	[request.parameters setObject:[_passwordField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"password"];
	[request send];
	TTDPRINT(@"Sent the login form");
}

/*
 *	Treat this just like an error in the model
 */
-(void) cancelLoginForm {
	_loginState = NotLoggedIn;
	NSError *error = [NSError errorWithDomain:@"Login" code:001 userInfo:nil];
	[_delegate request:nil didFailLoadWithError:error];
	[self dismissModalViewController];
	_delegate = nil;
	self.requestURL = nil;
}

#pragma mark -
#pragma mark Login Form TTTableViewController
-(void) viewDidLoad {
	UIBarButtonItem *loginButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitLoginForm)] autorelease];
	[self.navigationItem setRightBarButtonItem:loginButton];
	
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelLoginForm)] autorelease];
	[self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)createModel {
	TTDPRINT(@"Creating logintableview model");
	self.dataSource = [TTSectionedDataSource dataSourceWithItems:[NSArray arrayWithObject:[self tableItems]] sections:[NSArray arrayWithObject:@""]];
}

/**
 *	Shows an activity indicator when logging in, else the username/password fields
 */
- (NSArray *)tableItems {
	NSArray *tableItems = nil;
	if (_loginState == NotLoggedIn) {
		TTTableControlItem *usernameRow = [TTTableControlItem itemWithCaption:@"" control:_usernameField];
		TTTableControlItem *passwordRow = [TTTableControlItem itemWithCaption:@"" control:_passwordField];
		
		tableItems = [NSArray arrayWithObjects:usernameRow, passwordRow, nil];
	}
	else if (_loginState == LoggingIn) {
		tableItems = [NSArray arrayWithObject:[TTTableActivityItem itemWithText:@"Logging in..."]];
	}
	else if (_loginState == LoggedIn) {
		TTDPRINT(@"******Showing the login form when I'm logged in?? WTF???!?");
	}
	
	return tableItems;
}


@end
