//
//  ViewController.m
//  WebCache
//
//  Created by paschal on 15-2-2.
//  Copyright (c) 2015年 xxxx. All rights reserved.
//

#import "ViewController.h"
#import "PCURLProtocol.h"
#import "NSString+Utils.h"
//#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
@interface ViewController ()<UIGestureRecognizerDelegate,MJPhotoBrowserDelegate>{
    UIWebView *m_webView;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroudimage.png"]];
    [self.view sendSubviewToBack:imageView];
    [self.view addSubview:imageView];

    [NSURLProtocol registerClass:[PCURLProtocol class]];
    m_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    m_webView.delegate =(id <UIWebViewDelegate>)self;
    [self.view addSubview:m_webView];
    m_webView.scalesPageToFit = YES;
    [m_webView setBackgroundColor:[UIColor redColor]];
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"web" ofType:@"html"];
        NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    htmlString = [self getImageByHtmlContent:htmlString];
        [m_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
//    [m_webView stringByEvaluatingJavaScriptFromString:@"loadImage(1001,11,100,100)"];
//
    
//    [m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.smzdm.com/temp/video.html"]]];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    //    [self.view addGestureRecognizer:singleTap];
    
    [m_webView addGestureRecognizer:singleTap];
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *requestString = request.URL.absoluteString;

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    webView.allowsInlineMediaPlayback = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video')[0].setAttribute('webkit-playsinline','webkit-playsinline');"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video')[0].setAttribute('controls','controls');"];

//    [m_webView stringByEvaluatingJavaScriptFromString:@"loadImage(1001,11,100,100)"];
}

- (NSString *)getImageByHtmlContent:(NSString *)htmlContent
{
    NSString *tmpHtmlContent = [NSString stringWithFormat:@"%@",htmlContent];
    NSString *str = @"(?i)\\s*<img\\s*[^>]*>";
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:str
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSArray *matches = [regularexpression matchesInString:htmlContent
                                                  options:0
                                                    range:NSMakeRange(0, [htmlContent length])];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        
        NSString *result = [htmlContent substringWithRange:matchRange];
        NSString *imageSrc = [self getElement:@"src" ByString:result];
        NSString *attachmentid = [self getElement:@"attachmentid" ByString:result];
        
        NSString *replacejs = [result stringByReplacingOccurrencesOfString:@"<img" withString:[NSString stringWithFormat:@"<img pcpc=\"%@\"",imageSrc]];
        replacejs = [replacejs stringByReplacingOccurrencesOfString:@"src" withString:@"src='' 1234"];

        tmpHtmlContent = [tmpHtmlContent stringByReplacingOccurrencesOfString:result withString:replacejs];
        
    }
    return tmpHtmlContent;
    
}
- (NSString *)getElement:(NSString *)element ByString:(NSString *)string
{
    NSString *result = @"";
    if (element && string && element.length>0 && string.length > 0)
    {
        NSString *str =@"";
        if ([element isEqualToString:@"id"] || [element isEqualToString:@"attachmentid"]) {
            
            str = [NSString stringWithFormat:@"%@\\s*=\\s*\"\\s*([\\w]+)\\s*\"",element];
        }
        else if([element isEqualToString:@"src" ]|| [element isEqualToString:@"source"]) {
            
            str = [NSString stringWithFormat:@"%@\\s*=\\s*\"\\s*([^\"]+)\"",element];
            
        }
        else if([element isEqualToString:@"width"]||[element isEqualToString:@"w"] || [element isEqualToString:@"height"] || [element isEqualToString:@"h"]) {
            
            str = [NSString stringWithFormat:@"%@\\s*:\\s*([\\d]+)[px]?\\s*",element];
        }
        
        NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                                  initWithPattern:str
                                                  options:NSRegularExpressionCaseInsensitive
                                                  
                                                  error:nil];
        
        NSArray *matches = [regularexpression matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        
        if (matches.count > 0) {
            
            NSTextCheckingResult *match = [matches objectAtIndex:0];
            
            NSString *resultString = [string  substringWithRange:[match range]];
            
            NSRange range = [resultString rangeOfString:@"\""];
            
            if (range.location < resultString.length) {
                result = [resultString substringFromIndex:range.location+1];
                result = [result substringToIndex:result.length-1];
                
            }
        }
    }
    
    return result;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    CGPoint pt = [sender locationInView:m_webView];
    
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
//    NSString *js = @"document.body.innerHTML";

    NSString * tagName = [m_webView stringByEvaluatingJavaScriptFromString:js];
//    NSString *setSrc = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src=%@",pt.x, pt.y,@"http://upload.hbrchina.org/2014/1010/1412950010274.jpg"];
//    [m_webView stringByEvaluatingJavaScriptFromString:setSrc];
//    [m_webView reload];
//webkit-playsinline
    if ([tagName isEqualToString:@"IMG"]||[tagName isEqualToString:@"img"]) {
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
        NSString *xxx = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).width", pt.x, pt.y];
        
        NSString *yyy = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).height", pt.x, pt.y];
        
        NSString * offsetTop = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).offsetTop", pt.x, pt.y
                                ];
        
        NSString * offsetLeft = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).offsetLeft", pt.x, pt.y
                                 ];
        
        
        NSString *urlToSave = [m_webView stringByEvaluatingJavaScriptFromString:imgURL];
        
        CGFloat imageWith = [[m_webView stringByEvaluatingJavaScriptFromString:xxx] floatValue];
        CGFloat imageHeiht = [[m_webView stringByEvaluatingJavaScriptFromString:yyy] floatValue];
        CGFloat imageTop = [[m_webView stringByEvaluatingJavaScriptFromString:offsetTop] floatValue];
        CGFloat imageLeft = [[m_webView stringByEvaluatingJavaScriptFromString:offsetLeft] floatValue];
        CGRect showRect = CGRectMake(imageLeft, imageTop - m_webView.scrollView.contentOffset.y, imageWith, imageHeiht);
        
        NSLog(@"image url=%@,%f-%f-%f--%f", urlToSave,showRect.origin.x,showRect.origin.y,showRect.size.width,showRect.size.height);
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSLog(@"%@",docDir);
        
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.pc",docDir,[urlToSave toMD5]];
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = showRect;
        [imageView setImage:image];
        [self.view addSubview:imageView];
        imageView.tag = 1001;
        imageView.userInteractionEnabled = YES;
        // 内容模式
//        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:1];
        for (int i = 0; i<1; i++) {
            // 替换为中等尺寸图片
            
            MJPhoto *photo = [[MJPhoto alloc] init];
//            photo.url = [NSURL URLWithString:url]; // 图片路径
            photo.image = image;
            photo.srcImageView = imageView; // 来源于哪个UIImageView
            [photos addObject:photo];
        }
        
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        browser.delegate = self;
        [browser show];
    }
    
}

- (void)photoDidRemove:(MJPhotoBrowser *)photoBrowser{
    [[self.view viewWithTag:1001] removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
