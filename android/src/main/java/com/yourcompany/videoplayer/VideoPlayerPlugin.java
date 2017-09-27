package com.yourcompany.videoplayer;

import android.annotation.TargetApi;
import android.graphics.SurfaceTexture;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
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

public class VideoPlayerPlugin implements MethodCallHandler {
  private class VideoPlayer {
    @TargetApi(21)
    VideoPlayer(FlutterView view, String dataSource, final Result result) {
      this.view = view;
      imageId = FlutterView.createSurfaceTexture();
      SurfaceTexture surfaceTexture = FlutterView.getSurfaceTexture(imageId);
      surfaceTexture.setOnFrameAvailableListener(new SurfaceTexture.OnFrameAvailableListener() {
        @Override
        public void onFrameAvailable(SurfaceTexture texture) {
          VideoPlayer.this.view.markSurfaceTextureDirty(imageId);
        }
      });
      mediaPlayer = new MediaPlayer();
      try {
        mediaPlayer.setDataSource(dataSource);

        mediaPlayer.setSurface(new Surface(surfaceTexture));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
          mediaPlayer.setAudioAttributes(new AudioAttributes.Builder().setContentType(AudioAttributes.CONTENT_TYPE_MOVIE).build());
        } else {
          mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        }
        mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
          @Override
          public void onPrepared(MediaPlayer mp) {
            mediaPlayer.setLooping(true);
            result.success(imageId);
          }
        });
        mediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
          @Override
          public boolean onError(MediaPlayer mp, int what, int extra) {
            return true;
          }
        });
        mediaPlayer.prepareAsync();
      } catch (Exception e) {
        e.printStackTrace();
      }
    }

    public void play() {
      mediaPlayer.start();
    }

    public void pause() {
      mediaPlayer.pause();
    }

    public void seekTo(int location) {
      mediaPlayer.seekTo(location);
    }

    public int getDuration() {
      return mediaPlayer.getDuration();
    }

    public long getImageId() {
      return imageId;
    }

    public void dispose() {
      mediaPlayer.release();
    }

    private final FlutterView view;
    private final MediaPlayer mediaPlayer;
    private final long imageId;
  }
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
    if (call.method.equals("create")) {
      VideoPlayer videoPlayer = new VideoPlayer(view, (String)call.argument("dataSource"), result);
      videoPlayers.put(videoPlayer.getImageId(), videoPlayer);
    } else if (call.method.equals("play")) {
      long imageId = ((Number)call.argument("imageId")).longValue();
      VideoPlayer player = videoPlayers.get(imageId);
      player.play();
      result.success(true);
    } else if (call.method.equals("pause")) {
      long imageId = ((Number)call.argument("imageId")).longValue();
      VideoPlayer player = videoPlayers.get(imageId);
      player.pause();
      result.success(true);
    } else if (call.method.equals("seekTo")) {
      long imageId = ((Number)call.argument("imageId")).longValue();
      int location = ((Number)call.argument("location")).intValue();
      VideoPlayer player = videoPlayers.get(imageId);
      player.seekTo(location);
      result.success(true);
    } else if (call.method.equals("duration")) {
      long imageId = ((Number)call.argument("imageId")).longValue();
      VideoPlayer player = videoPlayers.get(imageId);
      result.success(player.getDuration());
    } else if (call.method.equals("dispose")) {
      long imageId = ((Number)call.argument("imageId")).longValue();
      VideoPlayer player = videoPlayers.remove(imageId);
      if (player != null) {
        player.dispose();
      }
      result.success(true);
    } else {
      result.notImplemented();
    }
  }
}
