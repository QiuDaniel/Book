//
//  MVUOpenUDID.h
//  MVUPowerVUI
//
//  Created by Daniel on 2018/7/16.
//  Copyright © 2018年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOpenUDIDErrorNone          0
#define kOpenUDIDErrorOptedOut      1
#define kOpenUDIDErrorCompromised   2

@interface MVUOpenUDID : NSObject

+ (NSString*)value;
+ (NSString*)valueWithError:(NSError**)error;
+ (void)setOptOut:(BOOL)optOutValue;

@end

