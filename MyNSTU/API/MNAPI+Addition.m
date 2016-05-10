//
//  MNAPI+Addition.m
//  My NSTU Design Only
//
//  Created by Dmitry on 06/02/15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNAPI+Addition.h"
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>
#define NSUD [NSUserDefaults standardUserDefaults]
#define time_pattern @"dd.MM.yy HH:mm:ss"
#define time_pattern_out @"dd.mm.yyyy"
@implementation MNAPI_Addition

+ (id) JSONObjectFromFile:(NSString*)filePath
{
    NSData* responseObject = [NSData dataWithContentsOfFile:filePath];
    id jsonObject;
    NSError *jsonError = nil;
    if(responseObject!=nil)
        jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
    return jsonObject;
}
+ (id) JSONObjectFromString:(NSString*) string{
    NSData* responseObject = [string dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject;
    NSError *jsonError = nil;
    if(responseObject!=nil)
        jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
    return jsonObject;
}
+ (CGRect) rectByLabel:(UILabel*) label andMaxWidth:(CGFloat) width
{
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    return newFrame;
}
+ (UIImage*) getImageFromID:(NSString*) _id
{
    UIImage *myCroppedImage;
    UIImage * myImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",_id]];
    return myImage;
    if(myImage == nil)
        return nil;
    int height = myImage.size.height,width = myImage.size.width;
    CGRect cropRect;
    if (height>width) {
        cropRect = CGRectMake(0.0, 0.0, width, width);
    }
    if(width>height)
        cropRect = CGRectMake(0.0, width/2-height/2, height, height);
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect([myImage CGImage], cropRect);
    
    myCroppedImage = [UIImage imageWithCGImage:croppedImage];
    
    CGImageRelease(croppedImage);
    
    return myCroppedImage;
}
+ (UIImage*)scaleTheImage:(UIImage*)image andRect:(CGSize) size
{
    UIImage *scaledImage;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+ (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    __block UIImage *cropped;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
        cropped = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    });
    return cropped;
}
+ (id) getViewControllerWithIdentifier:(NSString *)identifier
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    id viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    return viewController;
}

+ (id) getObjectFROMNSUDWithKey:(NSString*)key;
{
    [NSUD synchronize];
    return [NSUD objectForKey:key];
}
+ (void) setObjectTONSUD:(id)object withKey:(NSString*)key
{
    [NSUD synchronize];
    [NSUD setObject:object forKey:key];
    [NSUD synchronize];
}
+ (void) removeObjectFromNSUDWithKey:(NSString*)key
{
    [NSUD synchronize];
    [NSUD removeObjectForKey:key];
    [NSUD synchronize];
}

+ (void) changeContentViewControllerWithName:(NSString*)name
{
    IQSideMenuController *controller = [IQSideMenuController getNowUsedController];
    controller.contentViewController = [MNAPI_Addition getViewControllerWithIdentifier:name];
}

+ (void) changeContentViewControllerWithController:(id)_controller
{
    IQSideMenuController *controller = [IQSideMenuController getNowUsedController];
    controller.contentViewController = _controller;
}
+ (UIFont*)fontWithSize:(CGFloat)size;
{
    UIFont *font = [UIFont fontWithName:@"ionicons" size:size];
    return font;
}

+ (UILabel*)labelWithIcon:(NSString*)icon_name
                     size:(CGFloat)size
                    color:(UIColor*)color
{
    UILabel *label = [[UILabel alloc] init];
    [MNAPI_Addition label:label setIcon:icon_name size:size color:color sizeToFit:YES];
    return label;
}

+ (UIImage*)imageWithIcon:(NSString*)icon_name
                     size:(CGFloat)size
                    color:(UIColor*)color
{
    return [MNAPI_Addition imageWithIcon:icon_name
                         iconColor:color
                          iconSize:size
                         imageSize:CGSizeMake(size, size)];
}

+ (UIImage*)imageWithIcon:(NSString*)icon_name
                iconColor:(UIColor*)iconColor
                 iconSize:(CGFloat)iconSize
                imageSize:(CGSize)imageSize;
{
    NSAssert(icon_name, @"You must specify an icon from ionicons-codes.h.");
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6) {
        if (!iconColor) { iconColor = [UIColor blackColor]; }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
        NSAttributedString* attString = [[NSAttributedString alloc]
                                         initWithString:icon_name
                                         attributes:@{NSFontAttributeName: [MNAPI_Addition fontWithSize:iconSize],
                                                      NSForegroundColorAttributeName : iconColor}];
        // get the target bounding rect in order to center the icon within the UIImage:
        NSStringDrawingContext *ctx = [[NSStringDrawingContext alloc] init];
        CGRect boundingRect = [attString boundingRectWithSize:CGSizeMake(iconSize, iconSize) options:0 context:ctx];
        // draw the icon string into the image:
        [attString drawInRect:CGRectMake((imageSize.width/2.0f) - boundingRect.size.width/2.0f,
                                         (imageSize.height/2.0f) - boundingRect.size.height/2.0f,
                                         imageSize.width,
                                         imageSize.height)];
        UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (iconColor &&
            [iconImage respondsToSelector:@selector(imageWithRenderingMode:)]) {
            iconImage = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        return iconImage;
    } else {
#if DEBUG
        NSLog(@" [ IonIcons ] Using lower-res iOS 5-compatible image rendering.");
#endif
        UILabel *iconLabel = [MNAPI_Addition labelWithIcon:icon_name size:iconSize color:iconColor];
        UIImage *iconImage = nil;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1.0);
        {
            CGContextRef imageContext = UIGraphicsGetCurrentContext();
            if (imageContext != NULL) {
                UIGraphicsPushContext(imageContext);
                {
                    CGContextTranslateCTM(imageContext,
                                          (imageSize.width/2.0f) - iconLabel.frame.size.width/2.0f,
                                          (imageSize.height/2.0f) - iconLabel.frame.size.height/2.0f);
                    [[iconLabel layer] renderInContext: imageContext];
                }
                UIGraphicsPopContext();
            }
            iconImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        return iconImage;
    }
}
+ (void)label:(UILabel*)label
      setIcon:(NSString*)icon_name
         size:(CGFloat)size
        color:(UIColor*)color
    sizeToFit:(BOOL)shouldSizeToFit
{
    label.font = [MNAPI_Addition fontWithSize:size];
    label.text = icon_name;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    if (shouldSizeToFit) {
        [label sizeToFit];
    }
    // NOTE: ionicons will be silent through VoiceOver, but the Label is still selectable through VoiceOver. This can cause a usability issue because a visually impaired user might navigate to the label but get no audible feedback that the navigation happened. So hide the label for VoiceOver by default - if your label should be descriptive, un-hide it explicitly after creating it, and then set its accessibiltyLabel.
    label.accessibilityElementsHidden = YES;
}

+ (void) hideORShowLeftBar
{
    IQSideMenuController *sideController = [IQSideMenuController getNowUsedController];
    [sideController toggleMenuAnimated:YES];
}
@end

@implementation NSDate (MNAPIAddition)

- (NSString *) stringFromDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:time_pattern_out];
    NSString *stringFromDate = [formatter stringFromDate:self];
    return stringFromDate!=nil?stringFromDate:@"";
}

+ (NSDate *) dateFromString:(NSString*) string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:time_pattern];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}

@end

@implementation NSString (MNAPIAddition)

+ (NSString *) getJSONStringFromObject: (id)object
{
    NSString *jsonString;
    NSError *error = nil;
    NSData *json;
    if ([NSJSONSerialization isValidJSONObject:object])
    {
        json = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        if (json != nil && error == nil)
            jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        else NSLog(@"[MNHTTPAPI] + Addition: error getJSONStringFromObject - %@",error.description);
    }
    return jsonString;
}
- (NSString*) getMD5
{
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, sizeof(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
- (NSString*) encodeBase64
{
    NSData *nsdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    return base64Encoded;
}
- (NSString*) decodeBase64
{
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:self options:0];
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    return base64Decoded;
}
-(BOOL)isValidEmail
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
@end

@implementation IQSideMenuController (MNAPIAddition)

+ (IQSideMenuController *) getNowUsedController
{
    id test = [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if([rootVC isKindOfClass:[IQSideMenuController class]])
        return  (IQSideMenuController*)rootVC;
    else if([rootVC isKindOfClass:[UIWindow class]])
        return (IQSideMenuController *)((UIWindow*)rootVC).rootViewController;
    return nil;
}

+ (void) turnScroll
{
    [[IQSideMenuController getNowUsedController] disableOrEnableScroll];
}
@end

@implementation UIColor (MNAPIAddition)

+ (UIColor*) colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
@implementation UIImage (MNAPIAddition)

- (UIImage*)blurredImage:(CGFloat)blurAmount
{
    if (blurAmount < 0.0 || blurAmount > 1.0) {
        blurAmount = 0.5;
    }
    
    int boxSize = (int)(blurAmount * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (!error) {
        error = vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    }
    
    if (error) {
#ifdef DEBUG
        NSLog(@"%s error: %zd", __PRETTY_FUNCTION__, error);
#endif
        
        return self;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}
-(UIImage*)scaleTheImage:(CGSize) size
{
    UIImage *scaledImage;
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
@end

@implementation UIApplication (MNAPIAddition)


+ (NSString*) applicationDocumentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

@end