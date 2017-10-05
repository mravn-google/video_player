#import <AVFoundation/AVFoundation.h>
#import "VideoPlayerPlugin.h"

@interface VideoPlayer: NSObject<FlutterPlatformSurface>
@property(readonly, nonatomic) AVPlayer* player;
@property(readonly, nonatomic) AVPlayerItemVideoOutput* videoOutput;
@property(readonly, nonatomic) CADisplayLink* displayLink;
@property(nonatomic, copy) void (^onFrameAvailable)();
- (instancetype)initWithURL:(NSURL*)url;
- (void)play;
- (void)pause;
@end

@implementation VideoPlayer
- (instancetype)initWithURL:(NSURL*)url {
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
  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
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
  _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
  [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
  _displayLink.paused = YES;
  return self;
}

- (void)play {
  [_player play];
  _displayLink.paused = NO;
}

- (void)pause {
  [_player pause];
  _displayLink.paused = YES;
}

- (void)onDisplayLink:(CADisplayLink*)link {
  if (_onFrameAvailable) {
    _onFrameAvailable();
  }
}

- (CVPixelBufferRef)copyPixelBuffer {
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
    NSDictionary* argsMap = call.arguments;
    NSString* dataSource = argsMap[@"dataSource"];
    VideoPlayer* player = [[VideoPlayer alloc] initWithURL:[NSURL URLWithString:dataSource]];
    NSUInteger surfaceId = [_registry registerPlatformSurface:player];
    _players[@(surfaceId)] = player;
    player.onFrameAvailable = ^{
      [_registry platformSurfaceFrameAvailable:surfaceId];
    };
    result(@(surfaceId));
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
