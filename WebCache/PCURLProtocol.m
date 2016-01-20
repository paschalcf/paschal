//
//  PCURLProtocol.m
//  xxxx
//
//  Created by paschal on 15-2-2.
//
//

#import "PCURLProtocol.h"

#import "NSString+Utils.h"
@interface PCURLProtocol () <NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSURLConnection *connection;
@property (strong,nonatomic) NSMutableData *data;
@property (strong,nonatomic) NSString *MIMEType;

@end

@implementation PCURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    if ([NSURLProtocol propertyForKey:NSStringFromClass([self class])
                            inRequest:request]) {
        return NO;
    }
    NSString *urlString = request.URL.absoluteString;
    
    if ([[urlString pathExtension] isEqualToString:@"jpg"]||[[urlString pathExtension] isEqualToString:@"png"]) {
        return YES;
    }
    
    
    return NO;
}



+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    
    [NSURLProtocol setProperty:@YES
                        forKey:NSStringFromClass([self class])
                     inRequest:newRequest];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest
                                                    delegate:self];
    
    [self.connection start];
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    
    self.data = [NSMutableData data];
    
    self.MIMEType = [response MIMEType];
    
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self.MIMEType isEqualToString:@"text/html"]) {
        NSString *html = [[NSString alloc] initWithData:self.data
                                               encoding:NSUTF8StringEncoding];
        
        NSString *modifiedHTML = [html stringByReplacingOccurrencesOfString:@"Apple"
                                                                 withString:@"Fruit"];
        
        NSData *modifiedData = [modifiedHTML dataUsingEncoding:NSUTF8StringEncoding];
        
        [self.client URLProtocol:self
                     didLoadData:modifiedData];
        
    }else if([self.MIMEType hasPrefix:@"image"]){
       
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.pc",docDir,[self.request.URL.relativeString toMD5]];
        NSLog(@"%@",self.request.URL.absoluteString);
        NSLog(@"%@",docDir);
        [self.data writeToFile:pngFilePath atomically:YES];
        [self.client URLProtocol:self
                     didLoadData:self.data];
        
    }else {
        [self.client URLProtocol:self
                     didLoadData:self.data];
    }
    
    [self.client URLProtocolDidFinishLoading:self];
    
    self.connection = nil;
    self.data = nil;
    self.MIMEType = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",self.request.URL.absoluteString);

    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.pc",docDir,[self.request.URL.relativeString toMD5]];
    NSLog(@"%@",docDir);
    NSData *data = [[NSData alloc] initWithContentsOfFile:pngFilePath];
    if (data) {
        [self.client URLProtocol:self
                     didLoadData:data];
    }
}
@end
