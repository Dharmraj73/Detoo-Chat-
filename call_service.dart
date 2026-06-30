import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

/// Voice & Video calling service using Agora SDK
/// IMPORTANT: Sign up at https://www.agora.io (free tier available, works in India)
/// and replace 'YOUR_AGORA_APP_ID' below with your App ID.
class CallService extends ChangeNotifier {
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';

  RtcEngine? _engine;
  int? remoteUid;
  bool localUserJoined = false;
  bool isMuted = false;
  bool isVideoEnabled = true;

  Future<void> initializeCall({required bool isVideoCall}) async {
    await [Permission.microphone, if (isVideoCall) Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(appId: agoraAppId));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          localUserJoined = true;
          notifyListeners();
        },
        onUserJoined: (connection, uid, elapsed) {
          remoteUid = uid;
          notifyListeners();
        },
        onUserOffline: (connection, uid, reason) {
          remoteUid = null;
          notifyListeners();
        },
      ),
    );

    if (isVideoCall) {
      await _engine!.enableVideo();
      await _engine!.startPreview();
    } else {
      await _engine!.disableVideo();
    }
  }

  /// Join a call channel. channelName should be unique per chat/call.
  /// token should be generated from your backend server for production security.
  Future<void> joinChannel(String channelName, {String token = ''}) async {
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  void toggleMute() {
    isMuted = !isMuted;
    _engine?.muteLocalAudioStream(isMuted);
    notifyListeners();
  }

  void toggleVideo() {
    isVideoEnabled = !isVideoEnabled;
    _engine?.muteLocalVideoStream(!isVideoEnabled);
    notifyListeners();
  }

  void switchCamera() {
    _engine?.switchCamera();
  }

  RtcEngine? get engine => _engine;

  Future<void> leaveCall() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    localUserJoined = false;
    remoteUid = null;
    notifyListeners();
  }
}
