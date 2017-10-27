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
import io.flutter.view.TextureRegistry;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

public class VideoPlayerPlugin implements MethodCallHandler {
  private class VideoPlayer {
    private final TextureRegistry.SurfaceTextureEntry textureEntry;
    private final MediaPlayer mediaPlayer;

    @TargetApi(21)
    VideoPlayer(final TextureRegistry.SurfaceTextureEntry textureEntry, String dataSource, final Result result) {
      this.textureEntry = textureEntry;
      this.mediaPlayer = new MediaPlayer();
      try {
        mediaPlayer.setSurface(new Surface(textureEntry.surfaceTexture()));
        mediaPlayer.setDataSource(dataSource);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
          mediaPlayer.setAudioAttributes(new AudioAttributes.Builder().setContentType(AudioAttributes.CONTENT_TYPE_MOVIE).build());
        } else {
          mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        }
        mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
          @Override
          public void onPrepared(MediaPlayer mp) {
            mediaPlayer.setLooping(true);
            result.success(textureEntry.id());
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

    public long getTextureId() {
      return textureEntry.id();
    }

    public void dispose() {
      if (mediaPlayer.isPlaying()) {
        mediaPlayer.stop();
      }
      mediaPlayer.reset();
      mediaPlayer.release();
      textureEntry.release();
    }
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
      TextureRegistry.SurfaceTextureEntry handle = view.createSurfaceTexture();
      videoPlayers.put(handle.id(), new VideoPlayer(handle, (String)call.argument("dataSource"), result));
    } else if (call.method.equals("play")) {
      long textureId = ((Number)call.argument("textureId")).longValue();
      VideoPlayer player = videoPlayers.get(textureId);
      player.play();
      result.success(true);
    } else if (call.method.equals("pause")) {
      long textureId = ((Number)call.argument("textureId")).longValue();
      VideoPlayer player = videoPlayers.get(textureId);
      player.pause();
      result.success(true);
    } else if (call.method.equals("seekTo")) {
      long textureId = ((Number)call.argument("textureId")).longValue();
      int location = ((Number)call.argument("location")).intValue();
      VideoPlayer player = videoPlayers.get(textureId);
      player.seekTo(location);
      result.success(true);
    } else if (call.method.equals("duration")) {
      long textureId = ((Number)call.argument("textureId")).longValue();
      VideoPlayer player = videoPlayers.get(textureId);
      result.success(player.getDuration());
    } else if (call.method.equals("dispose")) {
      long textureId = ((Number)call.argument("textureId")).longValue();
      VideoPlayer player = videoPlayers.remove(textureId);
      if (player != null) {
        player.dispose();
      }
      result.success(true);
    } else {
      result.notImplemented();
    }
  }
}
