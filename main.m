//
//  main.m
//  Movies
//
//  Created by Patrick Quinn-Graham on 09/03/08.
//  Copyright Patrick Quinn-Graham 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"MoviesAppDelegate");
    [pool release];
    return retVal;
}
