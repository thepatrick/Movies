//
//  KeychainBridge.h
//  Movies
//
//  Created by Patrick Quinn-Graham on 16/03/08.
//  Copyright 2008 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KeychainBridge : NSObject {

}

+ (BOOL)checkForExistanceOfKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username;
+ (BOOL)modifyKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withNewPassword:(NSString *)newPassword;
+ (BOOL)addKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withPassword:(NSString *)password;
+ (NSString *)getPasswordFromKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username;

//+ (NSString *)getPasswordFromSecKeychainItemRef:(SecKeychainItemRef)item;

@end
