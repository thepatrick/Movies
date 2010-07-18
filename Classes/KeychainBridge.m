//
// KeychainBridge.m
// Based on code from "Core Mac OS X and Unix Programming"
// by Mark Dalrymple and Aaron Hillegass
// http://borkware.com/corebook/source-code
//
// Created by Adam Gerson on 3/6/05.
// agerson@mac.com
//

#import "KeychainBridge.h"

#import <CoreFoundation/CoreFoundation.h>
#import <Security/Security.h>

@implementation KeychainBridge

+ (BOOL)checkForExistanceOfKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username
{
	return NO;
//	SecKeychainSearchRef search;
//	SecKeychainItemRef item;
//	SecKeychainAttributeList list;
//	SecKeychainAttribute attributes[3];
    OSErr result;
    int numberOfItemsFound = 0;
	
	char *_username, *_keychainItemName, *_keychainItemKind;
	_username=(char *)malloc([username length]*sizeof(char));
	_keychainItemName=(char *)malloc([keychainItemName length]*sizeof(char));
	_keychainItemKind=(char *)malloc([keychainItemKind length]*sizeof(char));	
	strncpy(_username, [username cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [username length]);
	strncpy(_keychainItemName, [keychainItemName cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [keychainItemName length]);
	strncpy(_keychainItemKind, [keychainItemKind cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [keychainItemKind length]);
	
//	attributes[0].tag = kSecAccountItemAttr;
//    attributes[0].data = _username;
//    attributes[0].length = [username length];
//    
//    attributes[1].tag = kSecLabelItemAttr;
//    attributes[1].data = _keychainItemName;
//    attributes[1].length = [keychainItemName length];
//	
//	attributes[2].tag = kSecDescriptionItemAttr;
//    attributes[2].data = _keychainItemKind;
//    attributes[2].length = [keychainItemKind length];
//
//    list.count = 3;
//    list.attr = attributes;

//    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);

    if (result != noErr) {
        NSLog (@"status %d from SecKeychainSearchCreateFromAttributes\n", result);
    }
    
//	while (SecKeychainSearchCopyNext (search, &item) == noErr) {
//        CFRelease (item);
//        numberOfItemsFound++;
//    }

//    CFRelease (search);
	
	free(_username);
	free(_keychainItemName);
	free(_keychainItemKind);
	
	return numberOfItemsFound;
}


+ (BOOL)modifyKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withNewPassword:(NSString *)newPassword
{
	return NO;
//	SecKeychainAttribute attributes[3];
//    SecKeychainAttributeList list;
//    SecKeychainItemRef item;
//	SecKeychainSearchRef search;
    OSStatus status;
//	OSErr result;
	
	
	char *_username, *_keychainItemName, *_keychainItemKind;
	_username=(char *)malloc([username length]*sizeof(char));
	_keychainItemName=(char *)malloc([keychainItemName length]*sizeof(char));
	_keychainItemKind=(char *)malloc([keychainItemKind length]*sizeof(char));	
	strncpy(_username, [username cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [username length]);
	strncpy(_keychainItemName, [keychainItemName cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [keychainItemName length]);
	strncpy(_keychainItemKind, [keychainItemKind cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [keychainItemKind length]);
	
//    attributes[0].tag = kSecAccountItemAttr;
//    attributes[0].data = _username;
//	attributes[0].length = [username length];
//    
//    attributes[1].tag = kSecLabelItemAttr;
//    attributes[1].data = _keychainItemName;
//	attributes[1].length = [keychainItemName length];
//	
//	attributes[2].tag = kSecDescriptionItemAttr;
//    attributes[2].data = _keychainItemKind;
//	attributes[2].length = [keychainItemKind length];
//
//    list.count = 3;
//    list.attr = attributes;
//	
//	result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);
//	SecKeychainSearchCopyNext (search, &item);
//    status = SecKeychainItemModifyContent(item, &list, [newPassword length], [newPassword cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation]);
	
    if (status != 0) {
        NSLog(@"Error modifying item: %d", (int)status);
    }
//	 CFRelease (item);
//	 CFRelease(search);
	 
	free(_username);
	free(_keychainItemName);
	free(_keychainItemKind);
	
	return !status;
}

+ (BOOL)addKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username withPassword:(NSString *)password
{
	return NO;
//	SecKeychainAttribute attributes[3];
//    SecKeychainAttributeList list;
//    SecKeychainItemRef item;
    OSStatus status;
	
	char *_username, *_keychainItemName, *_keychainItemKind;
	_username=(char *)malloc([username length]*sizeof(char));
	_keychainItemName=(char *)malloc([keychainItemName length]*sizeof(char));
	_keychainItemKind=(char *)malloc([keychainItemKind length]*sizeof(char));	
	strncpy(_username, [username cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [username length]);
	strncpy(_keychainItemName, [keychainItemName cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [keychainItemName length]);
	strncpy(_keychainItemKind, [keychainItemKind cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [keychainItemKind length]);

	
//    attributes[0].tag = kSecAccountItemAttr;
//    attributes[0].data = _username;
//	attributes[0].length = [username length];
//    
//    attributes[1].tag = kSecLabelItemAttr;
//    attributes[1].data = _keychainItemName;
//	attributes[1].length = [keychainItemName length];
//	
//	attributes[2].tag = kSecDescriptionItemAttr;
//    attributes[2].data = _keychainItemKind;
//	attributes[2].length = [keychainItemKind length];
//
//    list.count = 3;
//    list.attr = attributes;

//	status = SecItemAdd(attributes, &item);

//    status = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass, &list, [password length], [password cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], NULL,NULL,&item);
    if (status != 0) {
        NSLog(@"Error creating new item: %d\n", (int)status);
    }
	
	free(_username);
	free(_keychainItemName);
	free(_keychainItemKind);

	return !status;
}

+ (NSString *)getPasswordFromKeychainItem:(NSString *)keychainItemName withItemKind:(NSString *)keychainItemKind forUsername:(NSString *)username
{
	return nil;
	
//    SecKeychainSearchRef search;
//    SecKeychainItemRef item;
//    SecKeychainAttributeList list;
//    SecKeychainAttribute attributes[3];
    OSErr result;

	char *_username, *_keychainItemName, *_keychainItemKind;
	_username=(char *)malloc([username length]*sizeof(char));
	_keychainItemName=(char *)malloc([keychainItemName length]*sizeof(char));
	_keychainItemKind=(char *)malloc([keychainItemKind length]*sizeof(char));	
	strncpy(_username, [username cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [username length]);
	strncpy(_keychainItemName, [keychainItemName cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [keychainItemName length]);
	strncpy(_keychainItemKind, [keychainItemKind cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], [keychainItemKind length]);


//	attributes[0].tag = kSecAccountItemAttr;
//    attributes[0].data = _username;
//	attributes[0].length = [username length];
//    
//    attributes[1].tag = kSecLabelItemAttr;
//    attributes[1].data = _keychainItemName;
//	attributes[1].length = [keychainItemName length];
//	
//	attributes[2].tag = kSecDescriptionItemAttr;
//    attributes[2].data = _keychainItemKind;
//	attributes[2].length = [keychainItemKind length];
//
//    list.count = 3;
//    list.attr = attributes;

//    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);

    if (result != noErr) {
        NSLog (@"status %d from SecKeychainSearchCreateFromAttributes\n", result);
    }
	
	NSString *password = @"error";
//    if (SecKeychainSearchCopyNext (search, &item) == noErr) {
//		password = [self getPasswordFromSecKeychainItemRef:item];
//		CFRelease(item);
//		CFRelease (search);
//	}
	
	free(_username);
	free(_keychainItemName);
	free(_keychainItemKind);
	
	return password;
}

//+ (NSString *)getPasswordFromSecKeychainItemRef:(SecKeychainItemRef)item
//{
//    UInt32 length;
//    char *password;
//    SecKeychainAttribute attributes[8];
//    SecKeychainAttributeList list;
//    OSStatus status;
//	
//    attributes[0].tag = kSecAccountItemAttr;
//    attributes[1].tag = kSecDescriptionItemAttr;
//    attributes[2].tag = kSecLabelItemAttr;
//    attributes[3].tag = kSecModDateItemAttr;
// 
//    list.count = 4;
//    list.attr = attributes;
//
//    status = SecKeychainItemCopyContent (item, NULL, &list, &length, 
//                                         (void **)&password);
//
//    // use this version if you don't really want the password,
//    // but just want to peek at the attributes
//    //status = SecKeychainItemCopyContent (item, NULL, &list, NULL, NULL);
//    
//    // make it clear that this is the beginning of a new
//    // keychain item
//    if (status == noErr) {
//        if (password != NULL) {
//
//            // copy the password into a buffer so we can attach a
//            // trailing zero byte in order to be able to print
//            // it out with printf
//            char passwordBuffer[1024];
//
//            if (length > 1023) {
//                length = 1023; // save room for trailing \0
//            }
//            strncpy (passwordBuffer, password, length);
//
//            passwordBuffer[length] = '\0';
//			//printf ("passwordBuffer = %s\n", passwordBuffer);
//			return [NSString stringWithCString:passwordBuffer];
//        }
//
//        SecKeychainItemFreeContent (&list, password);
//		return nil;
//
//    } else {
//        printf("Error = %d\n", (int)status);
//		return nil;
//    }
//	return nil;
//}

@end
