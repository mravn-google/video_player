#import <AVFoundation/AVFoundation.h>
#import "VideoPlayerPlugin.h"

@interface VideoPlayer: NSObject<FlutterPlatformSurface>
@property(readonly, nonatomic) AVPlayer* player;
@property(readonly, nonatomic) AVPlayerItemVideoOutput* videoOutput;
- (void)play;
- (void)pause;
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

- (void)play {
  [_player play];
}

- (void)pause {
  [_player pause];
}

- (BOOL)hasNewPixelBuffer {
  CMTime outputItemTime = [_videoOutput itemTimeForHostTime:CACurrentMediaTime()];
  return [_videoOutput hasNewPixelBufferForItemTime:outputItemTime];
}

- (CVPixelBufferRef)getPixelBuffer {
  CMTime outputItemTime = [_videoOutput itemTimeForHostTime:CACurrentMediaTime()];
  if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
    return [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
  } else {
    return NULL;
  }
}
@end

@interface VideoPlayerPlugin()
@property(readonly, nonatomic) NSObject<FlutterPlatformSurfaceRegistry>* registry;
@property(readonly, nonatomic) NSMutableDictionary* players;
@end

@implementation VideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"video_player"
            binaryMessenger:[registrar messenger]];
  VideoPlayerPlugin* instance = [[VideoPlayerPlugin alloc] initWithRegistry:[registrar platformSurfaceRegistry]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterPlatformSurfaceRegistry>*)registry {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = registry;
  _players = [NSMutableDictionary dictionaryWithCapacity:1];
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"create" isEqualToString:call.method]) {
    VideoPlayer* player = [[VideoPlayer alloc] init];
    NSUInteger imageId = [_registry registerPlatformSurface:player];
    _players[@(imageId)] = player;
    result(@(imageId));
  } else {
    NSDictionary* argsMap = call.arguments;
    NSUInteger surfaceId = ((NSNumber*) argsMap[@"surfaceId"]).unsignedIntegerValue;
    AVPlayer* player = _players[@(surfaceId)];
    if ([@"dispose" isEqualToString:call.method]) {
      [_players removeObjectForKey:@(surfaceId)];
      [_registry unregisterPlatformSurface:surfaceId];
    } else if ([@"play" isEqualToString:call.method]) {
      [player play];
    } else if ([@"pause" isEqualToString:call.method]) {
      [player pause];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
}

@end
