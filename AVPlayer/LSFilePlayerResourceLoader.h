////
////  LSFilePlayerResourceLoader.h
////  AVPlayer
////
////  Created by 强新宇 on 16/8/17.
////  Copyright © 2016年 强新宇. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import <AVFoundation/AVFoundation.h>
//@class LSFilePlayerResourceLoader;
//
//@protocol LSFilePlayerResourceLoaderDelegate <NSObject>
//
//@optional
//
//- (void)filePlayerResourceLoader:(LSFilePlayerResourceLoader *)resourceLoader
//                didFailWithError:(NSError *)error;
//
//- (void)filePlayerResourceLoader:(LSFilePlayerResourceLoader *)resourceLoader
//                 didLoadResource:(NSURL *)resourceURL;
//
//@end
//
//
//@interface LSFilePlayerResourceLoader : NSObject
//
//@property (nonatomic,readonly,strong)NSURL *resourceURL;
//@property (nonatomic,readonly)NSArray *requests;
//@property (nonatomic,readonly,strong)YDSession *session;
//@property (nonatomic,readonly,assign)BOOL isCancelled;
//
//@property (nonatomic,weak)id <LSFilePlayerResourceLoaderDelegate> delegate;
//
//- (instancetype)initWithResourceURL:(NSURL *)url session:(YDSession *)session;
//- (void)addRequest:(AVAssetResourceLoadingRequest *)loadingRequest;
//- (void)removeRequest:(AVAssetResourceLoadingRequest *)loadingRequest;
//- (void)cancel;
//
//@end