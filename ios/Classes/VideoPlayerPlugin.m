#import <AVFoundation/AVFoundation.h>
#import "VideoPlayerPlugin.h"

@interface VideoPlayer: NSObject<FlutterExternalImage>
@property(readonly, nonatomic) AVPlayer* player;
@property(readonly, nonatomic) AVPlayerItemVideoOutput* videoOutput;
@end

@implementation VideoPlayer
- (instancetype)init {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _player = [[AVPlayer alloc] init];
  _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
  [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                    object:[_player currentItem]
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification *note) {
    AVPlayerItem *p = [note object];
    [p seekToTime:kCMTimeZero];
  }];
  NSDictionary *pixBuffAttributes = @{
    (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
    (id)kCVPixelBufferIOSurfacePropertiesKey: @{}
  };
  _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_10mb.mp4"]];
  AVAsset *asset = [item asset];
  [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
      if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
          NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
          if ([tracks count] > 0) {
              AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
              [videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
                if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [item addOutput:_videoOutput];
                          [_player replaceCurrentItemWithPlayerItem:item];
                          [_player play];
                      });
                  }
              }];
          }
      }
  }];
  return self;
}

- (BOOL)hasNewImage {
  CMTime outputItemTime = [_videoOutput itemTimeForHostTime:CACurrentMediaTime()];
  return [_videoOutput hasNewPixelBufferForItemTime:outputItemTime];
}

- (CVPixelBufferRef)getImage {
  CMTime outputItemTime = [_videoOutput itemTimeForHostTime:CACurrentMediaTime()];
  if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
    return [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
  } else {
    return NULL;
  }
}
@end

@interface VideoPlayerPlugin()
@property(readonly, nonatomic) NSObject<FlutterExternalImageRegistry>* registry;
@property(readonly, nonatomic) NSMutableDictionary* players;
@end

@implementation VideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"video_player"
            binaryMessenger:[registrar messenger]];
  VideoPlayerPlugin* instance = [[VideoPlayerPlugin alloc] initWithRegistry:[registrar externalImageRegistry]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterExternalImageRegistry>*)registry {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = registry;
  _players = [NSMutableDictionary dictionaryWithCapacity:1];
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"createVideoPlayer" isEqualToString:call.method]) {
    VideoPlayer* player = [[VideoPlayer alloc] init];
    NSUInteger imageId = [_registry registerExternalImage:player];
    _players[@(imageId)] = player;
    result(@(imageId));
  } else if ([@"disposeVideoPlayer" isEqualToString:call.method]) {
    NSUInteger imageId = ((NSNumber*) call.arguments).unsignedIntegerValue;
    [_players removeObjectForKey:@(imageId)];
    [_registry unregisterExternalImage:imageId];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
