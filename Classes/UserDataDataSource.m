//
//  UserDataDataSource.m
//  LoginControllerExample
//
//  Created by Phillip Verheyden on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserDataDataSource.h"
#import "UserDataModel.h"

@implementation UserDataDataSource

- (void)tableViewDidLoadModel:(UITableView *)tableView {
	
}

-(NSString *)titleForEmpty{
	return @"No Results";
}
-(NSString *)subtitleForEmpty{
	return @"Try adding something!";
}

-(NSString *)titleForError:(NSError *)error{
	return @"Error";
}
-(NSString *)subtitleForError:(NSError *)error{
	return @"You must be logged in";
}


@end
