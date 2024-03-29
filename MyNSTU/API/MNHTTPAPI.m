//
//  MNHTTPAPI.m
//  MyNSTU
//
//  Created by Дмитрий Богомолов on 22.03.15.
//  Copyright (c) 2015 Дмитрий Богомолов. All rights reserved.
//

#import "MNHTTPAPI.h"
#import "AFNetworking.h"
@implementation MNHTTPAPI




- (NSString*) getTypeString:(MNNewsType)type
{
    switch (type) {
        case NewsNSTU:
            return @"news_nstu";
            break;
        case News_press_releases:
            return @"news_press_releases";
            break;
        default:
            break;
    }
    return @"";
}
- (void) parseNews:(id) jsonObject
{
    id newsArray = jsonObject;
    NSMutableArray *newsOutArray = [NSMutableArray new];
    [newsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(obj!=nil)
        {
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            [tempDict setObject:obj[@"title"] forKey:@"title"];
            [tempDict setObject:obj[@"pubdate"] forKeyedSubscript:@"pubdate"];
            //[tempDict setObject:temp!=nil?temp:[NSDate date] forKey:@"pubdate"];
            [tempDict setObject:obj[@"link"] forKey:@"link"];
            [tempDict setObject:obj[@"description"] forKey:@"description"];
            [newsOutArray addObject:tempDict];
        }
    }];
    [newsOutArray sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"pubdate" ascending:NO], nil]];
    if([self.delegate respondsToSelector:@selector(MNAPIDidRecieveNews:news:)])
        [self.delegate MNAPIDidRecieveNews:self news:newsOutArray];
    else NSLog(@"[MNHTTPAPI] Did not responds selector MNAPIDidRecieveNews:news:");
}
- (void) getAllNews
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@2/get_news",SERVER_ADDRESS] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self parseNews:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
- (void) getNewsWithCountNoOffset:(NSInteger) count
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@2/get_news",SERVER_ADDRESS] parameters:@{@"count": [NSNumber numberWithInteger:count]} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self parseNews:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
//    [manager GET:[NSString stringWithFormat:@"%@2/get_news",SERVER_ADDRESS] parameters:@{@"count": [NSNumber numberWithInteger:count]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *respString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        [self parseNews:respString];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//            [self.delegate MNHTTPError];
//    }];
}
- (void) getNewsWithCount:(NSInteger) count andOffset:(NSInteger) offset
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"%@2/get_news",SERVER_ADDRESS] parameters:@{@"count": [NSNumber numberWithInteger:count],@"offset":[NSNumber numberWithInteger:offset]} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self parseNews:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void) getFaculties
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@2/get_faculties",SERVER_ADDRESS] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveFaculties:andFacs:)])
                        [self.delegate MNHTTPDidRecieveFaculties:self andFacs:responseObject];
        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveFaculties:andFacs:");
//        NSArray *sortedKeys = [[responseObject allKeys] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
//        if([self.delegate respondsToSelector:@selector(MNHttpDidRecieveFacultiesResponse:andResults:sortedFacs:)])
//            [self.delegate MNHttpDidRecieveFacultiesResponse:self andResults:responseObject sortedFacs:sortedKeys];
//        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHttpDidRecieveFacultiesResponse:andResults:sortedFacs:");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:[NSString stringWithFormat:@"%@2/get_faculties",SERVER_ADDRESS] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveFaculties:andFacs:)])
//            [self.delegate MNHTTPDidRecieveFaculties:self andFacs:responseObject];
//        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveFaculties:andFacs:");
//        //        NSArray *sortedKeys = [[responseObject allKeys] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
//        //        if([self.delegate respondsToSelector:@selector(MNHttpDidRecieveFacultiesResponse:andResults:sortedFacs:)])
//        //            [self.delegate MNHttpDidRecieveFacultiesResponse:self andResults:responseObject sortedFacs:sortedKeys];
//        //        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHttpDidRecieveFacultiesResponse:andResults:sortedFacs:");
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error);
//        if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//            [self.delegate MNHTTPError];
//    }];
}
- (void) getScheduleFromGroup:(NSString*) group
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[[NSString stringWithFormat:@"%@2/get_schedule/%@",SERVER_ADDRESS,group] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"SCHEDULE!!!");
        NSLog(@"%@",responseObject);
        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveSchedule:andResults:andSemesterBegin:)])
            [self.delegate MNHTTPDidRecieveSchedule:self andResults:responseObject[@"data"] andSemesterBegin:responseObject[@"semester_begin"]];
        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveScdhedule:andResults:andSemesterBegin:");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:[[NSString stringWithFormat:@"%@2/get_schedule/%@",SERVER_ADDRESS,group] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"SCHEDULE!!!");
//        NSLog(@"%@",responseObject);
//        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveSchedule:andResults:andSemesterBegin:)])
//            [self.delegate MNHTTPDidRecieveSchedule:self andResults:responseObject[@"data"] andSemesterBegin:responseObject[@"semester_begin"]];
//        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveScdhedule:andResults:andSemesterBegin:");
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//            [self.delegate MNHTTPError];
//    }];
}

- (void) getBanners
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@2/get_banners",SERVER_ADDRESS] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveBanners:andBanners:)])
            [self.delegate MNHTTPDidRecieveBanners:self andBanners:responseObject];
        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveBanners:andBanners:");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:[NSString stringWithFormat:@"%@2/get_banners",SERVER_ADDRESS]  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveBanners:andBanners:)])
//            [self.delegate MNHTTPDidRecieveBanners:self andBanners:responseObject];
//        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveBanners:andBanners:");
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//            [self.delegate MNHTTPError];
//    }];
}

- (void) getOneNews: (NSString*) newsId
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@2/get_news_by_nstuid/%@",SERVER_ADDRESS,newsId] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveOneNews:andOneNews:)])
            [self.delegate MNHTTPDidRecieveOneNews:self andOneNews:responseObject[0]];
        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveOneNews:andOneNews:");

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSLog(@"%@",[NSString stringWithFormat:@"%@2/get_news_by_nstuid/%@",SERVER_ADDRESS,newsId]);
//    [manager GET:[NSString stringWithFormat:@"%@2/get_news_by_nstuid/%@",SERVER_ADDRESS,newsId]  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveOneNews:andOneNews:)])
//            [self.delegate MNHTTPDidRecieveOneNews:self andOneNews:responseObject[0]];
//        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveOneNews:andOneNews:");
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//            [self.delegate MNHTTPError];
//    }];
}
+ (BOOL) isAuthed
{
    BOOL authed = ((NSNumber*)[MNAPI_Addition getObjectFROMNSUDWithKey:@"authed"]).boolValue;
    return authed;
}
- (void) checkUsername: (NSString*) username
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:[NSString stringWithFormat:@"%@user/check_username?username=%@",SERVER_ADDRESS,username]  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveCheckUsernameResult:andResult:)])
//            [self.delegate MNHTTPDidRecieveCheckUsernameResult:self andResult:((NSNumber*)responseObject[@"answer"]).boolValue];
//        else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveOneNews:andOneNews:");
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//            [self.delegate MNHTTPError];
//    }];
}
- (void) authUser: (NSString*) username andPassword:(NSString*) password
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@user/auth",SERVER_ADDRESS] parameters:@{ @"username": username,@"password": password,@"device_id": UUID }
     	progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
		NSLog(@"%@", responseObject);
      	if(((NSNumber*)responseObject[@"succeed"]).boolValue)
      	{
      	    if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveAuthSuccess:andToken:userData:)])
      	        [self.delegate MNHTTPDidRecieveAuthSuccess:self andToken:responseObject[@"device_token"] userData:responseObject[@"user_info"]];
       	   else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthSuccess:andToken:");
     	 }
     	 else
         {
      	    if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveAuthFail:)])
          	    [self.delegate MNHTTPDidRecieveAuthFail:self];
       	   else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthFail:");
     	 }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          if([self.delegate respondsToSelector:@selector(MNHTTPError)])
              [self.delegate MNHTTPError];
    }];
//    NSLog(@"auth pass: %@ %@", [password getMD5], password);
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@user/auth",SERVER_ADDRESS]  parameters:@{ @"username": username,
//                                                                                           @"password": password,
//                                                                                           @"device_id": UUID }
//          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              NSLog(@"%@", responseObject);
//              if(((NSNumber*)responseObject[@"succeed"]).boolValue)
//              {
//                  if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveAuthSuccess:andToken:userData:)])
//                      [self.delegate MNHTTPDidRecieveAuthSuccess:self andToken:responseObject[@"device_token"] userData:responseObject[@"user_info"]];
//                  else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthSuccess:andToken:");
//              }
//              else
//              {
//                  if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveAuthFail:)])
//                      [self.delegate MNHTTPDidRecieveAuthFail:self];
//                  else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthFail:");
//              }
//              
//          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//                  [self.delegate MNHTTPError];
//          }];
}
- (void) regUser: (NSString*) username
     andPassword: (NSString*) password
         andName: (NSString*) name
      andSurname: (NSString*) surname
        andEmail: (NSString*) email
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@user/reg",SERVER_ADDRESS] parameters:@{ @"username": username,@"password": password,@"device_id": UUID }
//         progress:^(NSProgress * _Nonnull downloadProgress) {
//             
//         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//             NSLog(@"%@", responseObject);
//             if(((NSNumber*)responseObject[@"succeed"]).boolValue)
//             {
//                 if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveAuthSuccess:andToken:userData:)])
//                     [self.delegate MNHTTPDidRecieveAuthSuccess:self andToken:responseObject[@"device_token"] userData:responseObject[@"user_info"]];
//                 else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthSuccess:andToken:");
//             }
//             else
//             {
//                 if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveAuthFail:)])
//                     [self.delegate MNHTTPDidRecieveAuthFail:self];
//                 else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthFail:");
//             }
//             
//         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//             
//         }];
//    
//    
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@user/reg",SERVER_ADDRESS]  parameters:@{ @"username": username,
//                                                                                          @"password": [password getMD5],
//                                                                                          @"device_id": UUID,
//                                                                                          @"name": name,
//                                                                                          @"surname": surname,
//                                                                                          @"email": email}
//          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              if(((NSNumber*)responseObject[@"succeed"]).boolValue)
//              {
//                  if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveRegSuccess:andToken:)])
//                      [self.delegate MNHTTPDidRecieveRegSuccess:self andToken:responseObject[@"device_token"]];
//                  else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveRegSuccess:andToken:");
//              }
//              else
//              {
//                  if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveRegFail:andReason:)])
//                      [self.delegate MNHTTPDidRecieveRegFail:self andReason:responseObject[@"reason"]];
//                  else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthFail:");
//                  
//              }
//              
//              
//          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//                  [self.delegate MNHTTPError];
//          }];
}

- (void) getInfo
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:[NSString stringWithFormat:@"%@user/get_info",SERVER_ADDRESS]  parameters:@{@"device_id": UUID,
//                                                                                             @"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"]
//                                                                                             }
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveInfo:andInfo:)])
//                 [self.delegate MNHTTPDidRecieveInfo:self andInfo:responseObject];
//             else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveInfo:andInfo:");
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//                 [self.delegate MNHTTPError];
//         }];
}


- (void) setSchedule:(id) scheduleData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@user/set_schedule",SERVER_ADDRESS] parameters:@{ @"device_id": UUID,@"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],@"device_type": @1,@"schedule_data": [NSString getJSONStringFromObject:scheduleData] }
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSLog(@"%@", responseObject);
         if(((NSNumber*)responseObject[@"succeed"]).boolValue)
         {
             if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveAuthSuccess:andToken:userData:)])
                 [self.delegate MNHTTPDidRecieveAuthSuccess:self andToken:responseObject[@"device_token"] userData:responseObject[@"user_info"]];
             else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthSuccess:andToken:");
         }
         else
         {
             if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveAuthFail:)])
                 [self.delegate MNHTTPDidRecieveAuthFail:self];
             else NSLog(@"[MNHTTPAPI] Did not responds selector MNHTTPDidRecieveAuthFail:");
         }
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if([self.delegate respondsToSelector:@selector(MNHTTPError)])
             [self.delegate MNHTTPError];
     }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@user/set_schedule",SERVER_ADDRESS]  parameters:@{
//                                                                                                  @"device_id": UUID,
//                                                                                                  @"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],
//                                                                                                  @"device_type": @1,
//                                                                                                  @"schedule_data": [NSString getJSONStringFromObject:scheduleData]}
//          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              if(((NSNumber*)responseObject[@"succeed"]).boolValue)
//              {
//                  NSLog(@"setted schedule");
//              }
//              else
//              {
//                  
//                  
//              }
//              
//              
//          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//                  [self.delegate MNHTTPError];
//          }];
}
- (void) getSchedule
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:[NSString stringWithFormat:@"%@user/get_schedule",SERVER_ADDRESS]  parameters:@{@"device_id": UUID,
//                                                                                                 @"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],
//                                                                                                 @"device_type": @1
//                                                                                                 }
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             id schedule = [MNAPI_Addition JSONObjectFromString:(NSString*)responseObject[@"schedule_data"]];
//             NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"schedules.plist"];
//             NSData *datad = [NSKeyedArchiver archivedDataWithRootObject:schedule];
//             [datad writeToFile:plistPath atomically:YES];
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//                 [self.delegate MNHTTPError];
//         }];
}

- (void) getSemesterResults
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@user/get_session_results",SERVER_ADDRESS] parameters:@{ @"device_id": UUID,@"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],@"device_type": @1 }
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveSessionResults:andResults:)])
             [self.delegate MNHTTPDidRecieveSessionResults:self andResults:responseObject];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if([self.delegate respondsToSelector:@selector(MNHTTPError)])
             [self.delegate MNHTTPError];
     }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@user/get_session_results",SERVER_ADDRESS]  parameters:@{@"device_id": UUID,
//                                                                                                 @"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],
//                                                                                                 @"device_type": @1
//                                                                                                 }
//    success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveSessionResults:andResults:)])
//            [self.delegate MNHTTPDidRecieveSessionResults:self andResults:responseObject];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//            [self.delegate MNHTTPError];
//    }];
}
- (void) getMonitoringWeekResults
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@user/get_session_results",SERVER_ADDRESS] parameters:@{ @"device_id": UUID,@"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],@"device_type": @1 }
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveMonitoringWeekResults:andResults:)])
           [self.delegate MNHTTPDidRecieveMonitoringWeekResults:self andResults:responseObject];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if([self.delegate respondsToSelector:@selector(MNHTTPError)])
             [self.delegate MNHTTPError];
     }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@user/get_monitoring_week_results",SERVER_ADDRESS]  parameters:@{@"device_id": UUID,
//                                                                                                          @"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],
//                                                                                                          @"device_type": @1
//                                                                                                          }
//      success:^(AFHTTPRequestOperation *operation, id responseObject) {
//          if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveMonitoringWeekResults:andResults:)])
//              [self.delegate MNHTTPDidRecieveMonitoringWeekResults:self andResults:responseObject];
//      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//          if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//              [self.delegate MNHTTPError];
//      }];
}
- (void) getMessages
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@user/get_session_results",SERVER_ADDRESS] parameters:@{ @"device_id": UUID,@"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],@"device_type": @1 }
     progress:^(NSProgress * _Nonnull downloadProgress) {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveSessionResults:andResults:)])
           [self.delegate MNHTTPDidRecieveSessionResults:self andResults:responseObject];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if([self.delegate respondsToSelector:@selector(MNHTTPError)])
             [self.delegate MNHTTPError];
     }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@user/get_session_results",SERVER_ADDRESS]  parameters:@{@"device_id": UUID,
//                                                                                                         @"device_token": [MNAPI_Addition getObjectFROMNSUDWithKey:@"device_token"],
//                                                                                                         @"device_type": @1
//                                                                                                         }
//      success:^(AFHTTPRequestOperation *operation, id responseObject) {
//          if([self.delegate respondsToSelector:@selector(MNHTTPDidRecieveSessionResults:andResults:)])
//              [self.delegate MNHTTPDidRecieveSessionResults:self andResults:responseObject];
//      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//          if([self.delegate respondsToSelector:@selector(MNHTTPError)])
//              [self.delegate MNHTTPError];
//      }];
}
@end
