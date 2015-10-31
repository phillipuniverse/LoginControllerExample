###Assumptions
- Whatever URL you are trying to send to will be able to handle a username/password submission, as well as send back cookies (if necessary)
- Your server is using XML to send results back
- There is an XML element named `login_status` which has either a 1 or a 0 depending on whether or not the user is successfully logged in 
- You are using TTNavigator (so that the login form can pop up)
- You have something in your URLMap that maps to "tt://loginForm" and points to the LoginController class

###Features
- Saves successful username/password into NSUserDefaults (as `username` and `password`)
- Saves returned cookies (if any) into NSUserDefaults (as `cookies`)
- Shows a login form (simply username and password) with an unsuccessful login attempt (aka, `login_status == 0`)

###Problems
- Username/passsword is just sent unsecurely through POST variables.  In the future I'd like to implement some sort of OAuth or other secure communication method without using https

###Usage
Just call:

```
    [[LoginController loginController] sendRequestWithURL:@"http://domain.com/xml/data" delegate:self]

	from whatever `<TTURLRequestDelegate>` needs authentication support
```

###Algorithm
1. Some sort of `<TTURLRequestDelegate>` (could be a model to display data, or something that calls some function that requires authentication) calls the method: [[LoginController loginController] sendRequestWithURL:@"http://domain.com/xml/data/" delegate: self]
2. The login controller sends a request to that URL
3. If it sees `login_status == 0`:
	1. If there is a username/password in NSUserDefaults, resend the request using those credentials
	2. No username/password set, show the login form which has a textfield for username and password, a cancel button and a login button.
		1. If the cancel button is pushed, the delegate's `request:didFailLoadWithError: method is called
		2. The login button submits the form (as well as hitting "Go" on the password field)
		3. Once the form is submitted, it tries to go to that URL again, this time using the submitted username/password.  Also, a "Loading..." view is shown in place of the username/password fields.
			1. If the login is unsuccessful this time, an alert is shown that says it was a bad username/password
			2. If the login is successful, the login form gets dismissed, cookie data is saved, the username and password is saved, and the delegate's `requestDidFinishLoad:` method is called
4. If it sees `login_status == 1`, it saves any cookies into `NSUserDefaults` and then calls the delegate's `requestDidFinishLoad:`
