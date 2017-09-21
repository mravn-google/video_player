package com.yourcompany.videoplayer;

import android.graphics.SurfaceTexture;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.view.Surface;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

/**
 * VideoPlayerPlugin
 */
public class VideoPlayerPlugin implements MethodCallHandler {
  private class VideoPlayer {
    VideoPlayer(FlutterView view, String dataSource) {
      this.view = view;
      imageId = FlutterView.createSurfaceTexture();
      SurfaceTexture surfaceTexture = FlutterView.getSurfaceTexture(imageId);
      surfaceTexture.setOnFrameAvailableListener(new SurfaceTexture.OnFrameAvailableListener() {
        @Override
        public void onFrameAvailable(SurfaceTexture texture) {
          VideoPlayer.this.view.markSurfaceTextureDirty(imageId);
        }
      });
      Log.e(TAG, "Creating media player");
      mediaPlayer = new MediaPlayer();
      try {
        mediaPlayer.setDataSource(dataSource);

        mediaPlayer.setSurface(new Surface(surfaceTexture));
        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
          @Override
          public void onPrepared(MediaPlayer mp) {
            mp.setLooping(true);
            mp.start();
          }
        });
        mediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
          @Override
          public boolean onError(MediaPlayer mp, int what, int extra) {
            Log.e(TAG, "Mediaplayer error " + what);
            return true;
          }
        });
        mediaPlayer.prepareAsync();
      } catch (Exception e) {
        Log.e(TAG, "Mediaplayer setup error ");
        e.printStackTrace();
      }
    }

    public long getImageId() {
      return imageId;
    }

    public void dispose() {
      Log.e(TAG, "Releaseing media player");
      mediaPlayer.release();
    }

    private final FlutterView view;
    private final MediaPlayer mediaPlayer;
    private final long imageId;
  }
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "video_player");
    channel.setMethodCallHandler(new VideoPlayerPlugin(registrar.view()));
  }

  private VideoPlayerPlugin(FlutterView view) {
    this.view = view;
  }

  static final String TAG = "FlutterView";
  static private Map<Long, VideoPlayer> videoPlayers = new HashMap<>();
  private final FlutterView view;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("createVideoPlayer")) {
      VideoPlayer videoPlayer = new VideoPlayer(view, (String)call.argument("dataSource"));
      videoPlayers.put(videoPlayer.getImageId(), videoPlayer);
      result.success(videoPlayer.getImageId());
    } else if (call.method.equals("disposeVideoPlayer")) {
      long imageId = ((Number)call.argument("imageId")).longValue();
      Log.e(TAG, "Disposing videoplayer " + imageId);
      final VideoPlayer player = videoPlayers.remove(imageId);
      if (player != null) {
        player.dispose();
      }
      result.success(true);
    } else {
      result.notImplemented();
    }
  }
}
