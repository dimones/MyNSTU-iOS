//
//  MNHTTPAPI.h
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.03.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNAPI+Addition.h"
#define SERVER_ADDRESS @"https://api.mynstu.xyz/"

enum MNAPIConnectStatus
{
    MNAPIConnected = 0,
    MNAPINotConnected
};
typedef enum MNAPIConnectStatus MNAPIConnectStatus;

enum MNAPIStatus
{
    MNAPINoError = 1,
    MNAPIUserExist,
    MNAPIDataWrong
};
typedef enum MNAPIStatus MNAPIStatus;

enum MNAPIResponseType
{
    MNAPIResponseAuth = 1,
    MNAPIResponseGetNews,
    MNAPIResponseGetNewsLength,
    MNAPIResponseGetSessionResults,
    MNAPIResponseGetSessionResultsLength
};
typedef enum MNAPIResponseType MNAPIResponseType;

typedef enum : NSUInteger {
    NewsNSTU,
    News_press_releases,
    News_group,
    News_dev,
    News_favourite
} MNNewsType;


@class MNHTTPAPI;

@protocol MNAPIHTTPDelegate <NSObject>
@optional
- (void) MNAPIDidErrorConnectToServer: (NSError*) error;

- (void) MNHTTPError;

- (void) MNAPIRecieveResponse: (MNHTTPAPI*) api
                      message: (NSString*) message;

- (void) MNAPIDidRecieveAuthResponse: (MNHTTPAPI*) api
                               token: (NSString*) token
                           andStatus: (MNAPIStatus) status;
- (void) MNAPIDidRecieveAuthResponse: (MNHTTPAPI*) api
                                news: (NSString*) json
                           andStatus: (MNAPIStatus) status;
- (void) MNAPIDidRecieveNews: (MNHTTPAPI*) api
                        news: (NSArray*) news;

- (void) MNAPIDidRecieveSessionResults: (MNHTTPAPI*) api
                            andResults: (NSArray*) sessionResults;

- (void) MNHTTPDidRecievePersonSearchResults: (MNHTTPAPI*) api
                                  andResults: (NSArray*) personResults;
- (void) MNHttpDidRecieveFacultiesResponse: (MNHTTPAPI*) api
                                andResults: (id) results
                                sortedFacs: (NSArray*)facs;
- (void) MNHTTPDidRecieveSchedule: (MNHTTPAPI*) api
                       andResults: (NSArray*) results
                 andSemesterBegin: (NSString*) semesterBegin;
- (void) MNHTTPDidRecieveBanners: (MNHTTPAPI*) api
                      andBanners: (id)banners;
- (void) MNHTTPDidRecieveOneNews: (MNHTTPAPI*) api
                      andOneNews: (id) news;
- (void) MNHTTPDidRecieveFaculties: (MNHTTPAPI*) api
                           andFacs: (id) faculties;
@end


@interface MNHTTPAPI : NSObject
{
    __weak id <MNAPIHTTPDelegate> apiDelegate;
    __weak NSString* token;
    BOOL needRead;
    MNNewsType tempType;
}

@property (nonatomic, weak) id <MNAPIHTTPDelegate> delegate;

- (void) getAllNews;
- (void) getNewsWithCountNoOffset:(NSInteger) count;
- (void) getNewsWithCount:(NSInteger) count andOffset:(NSInteger) offset;
- (void) getFaculties;
- (void) getScheduleFromGroup:(NSString*) group;
- (void) searchWithQuery:(NSString*)query;
- (void) downloadAllPersRepo;
+ (BOOL) isAuthed;

//v2 begin

- (void) getBanners;
- (void) getOneNews: (NSString*) newsId;


@end
