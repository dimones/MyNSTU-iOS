//
//  MNAPI+Addition.h
//  My NSTU Design Only
//
//  Created by Dmitry on 06/02/15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQSideMenuController.h"
#import "ionicons-codes.h"
@interface MNAPI_Addition : NSObject
+ (id) JSONObjectFromFile:(NSString*)filePath;
+ (id) JSONObjectFromString:(NSString*) string;
+ (CGRect) rectByLabel:(UILabel*) label andMaxWidth:(CGFloat) width;
+ (UIImage*) getImageFromID:(NSString*) _id;
+ (UIImage*)scaleTheImage:(UIImage*)image andRect:(CGSize) size;
+ (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect;
+ (id) getViewControllerWithIdentifier: (NSString*)identifier;
+ (id) getObjectFROMNSUDWithKey:(NSString*)key;
+ (void) setObjectTONSUD:(id)object withKey:(NSString*)key;
+ (void) removeObjectFromNSUDWithKey:(NSString*)key;
+ (void) changeContentViewControllerWithName:(NSString*)name;
+ (void) changeContentViewControllerWithController:(id)controller;
+ (UIImage*)imageWithIcon:(NSString*)icon_name
                     size:(CGFloat)size
                    color:(UIColor*)color;

+ (UIImage*)imageWithIcon:(NSString*)icon_name
                iconColor:(UIColor*)color
                 iconSize:(CGFloat)iconSize
                imageSize:(CGSize)imageSize;
+ (UIFont*)fontWithSize:(CGFloat)size;


+ (UILabel*)labelWithIcon:(NSString*)icon_name
                     size:(CGFloat)size
                    color:(UIColor*)color;

+ (void)label:(UILabel*)label
      setIcon:(NSString*)icon_name
         size:(CGFloat)size
        color:(UIColor*)color
    sizeToFit:(BOOL)shouldSizeToFit;
+ (void) hideORShowLeftBar;
+ (UIColor*) getColorFromMARK14:(NSString*) mark14;
+ (UIColor*) getColorFromMARK:(NSNumber*) mark;
@end

@interface NSDate (MNAPIAddition)

- (NSString *) stringFromDate;

+ (NSDate *) dateFromString:(NSString*) string;

@end

@interface NSString (MNAPIAddition)

+ (NSString *) getJSONStringFromObject: (id)object;
- (NSString *) getMD5;
- (NSString*) encodeBase64;
- (NSString*) decodeBase64;
- (BOOL)isValidEmail;
@end

@interface IQSideMenuController (MNAPIAddition)

+ (IQSideMenuController *) getNowUsedController;
+ (void) turnScroll;
@end
@interface UINavigationController (MNAPIAddition)

@property (nonatomic, copy) void (^didDismiss)();
@end
@interface UIColor (MNAPIAddition)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end

@interface UIImage (MNAPIAddition)
- (UIImage*)scaleTheImage:(CGSize) size;
- (UIImage*)blurredImage:(CGFloat)blurAmount;

@end
@interface UIApplication (MNAPIAddition)
+ (NSString*) applicationDocumentDirectory;
@end
