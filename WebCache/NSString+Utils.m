//
//  NSString+Utils.m
//  HealthChat
//
//  Created by paschal on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Utils)
@dynamic isValidate;
@dynamic isPhoneNumber;
@dynamic isEmail;
@dynamic isTelephone;
@dynamic documentPath;
@dynamic temporaryPath;
@dynamic toMD5;
@dynamic bundlePath;
@dynamic isMD5;

+ (NSString *)uuid {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    CFRelease(uuid);
    return uuidString;
}

- (BOOL)isMD5 {
    return [self validateWithReg:@"^[a-fA-F0-9]{32,32}$"];
}
//
//- (BOOL)isWebSite {
//    
//}

- (BOOL)isServerPath {
    return self.length && [self characterAtIndex:0] == '/';
}

- (NSString *)toMD5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}


- (BOOL)isValidate {
    return self.length > 0;
}

- (BOOL)isContainsChinese
{
    int letter;
    for (int i = 0; i < self.length; i++) {
        letter = [self characterAtIndex:i];
        if (letter > 255) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)validateWithReg:(NSString *)regular {
    return [[[NSRegularExpression alloc] initWithPattern:regular options:0 error:nil] firstMatchInString:self options:0 range:NSMakeRange(0, self.length)] != nil;
}

- (BOOL)isPhoneNumber {
//    NSString *phoneReg = @"^((13[0-9])|(15[^4,\\D])|(14[5,7])|(18[0,2,3,5-9]))\\d{8}$";
    NSString *phoneReg = @"^\\d{11}$";
    return [self validateWithReg:phoneReg];
}

- (BOOL)isEmail {
//    NSString *emailReg = @"^\\w+((-\\w+)|(\\.\\w+))*\\@[0-9a-zA-Z]+((-|\\.)[0-9a-zA-Z]+)*\\.[0-9a-zA-Z]+$";
    NSString *emailReg = @"^\\w*@\\w*.[\\w\\d.]*$";
    return [self validateWithReg:emailReg];
}

- (BOOL)isTelephone {
    return [self validateWithReg:@"^(\\d{2,5}-\\d{7,8}(-\\d{1,})?)|(13\\d{9})|(159\\d{8})$"];
}
//该正则表达式存在问题
- (BOOL)isPostcode {
    return [self validateWithReg:@"[1-9]\\d{5}(?!\\d)"];
}



- (NSString *)bundlePath {
    if ([self characterAtIndex:0] == '/') {
        return [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"%@",self];
    }else {
        return [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/%@",self];
    }
}

- (NSString *)temporaryPath {
    if ([self characterAtIndex:0] == '/') {
        return [NSTemporaryDirectory() stringByAppendingFormat:@"%@",self];
    }else {
        return [NSTemporaryDirectory() stringByAppendingFormat:@"/%@",self];
    }
}

- (NSString *)documentPath {
    if ([self characterAtIndex:0] == '/') {
        return [NSHomeDirectory() stringByAppendingFormat:@"/Documents%@",self];
    } else {
        return [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",self];
    }
}










- (NSInteger)count {
    int i,n = [self length],l = 0,a = 0,b = 0;
    unichar c;
    for(i = 0;i < n;i++) {
        c = [self characterAtIndex:i];
        if(isblank(c)) {
            b++;
        } else if(isascii(c)) {
            a++;
        } else {
            l++;
        }
    }
    if (a == 0 && l == 0) {
        return 0;
    }
    return l+(int)ceilf((float)(a+b)/2.0);
}
@end


@implementation NSMutableString (Extensions)
- (NSMutableString *)deleteLastCharacter {
    int length = self.length;
    if (length) {
        [self deleteCharactersInRange:NSMakeRange(length - 1, 1)];
    }
    return self;
}

@end