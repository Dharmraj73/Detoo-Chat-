import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final bool isVideoCall;
  final String remoteUserName;

  const CallScreen({
    super.key,
    required this.channelName,
    required this.isVideoCall,
    required this.remoteUserName,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late CallService _callService;

  @override
  void initState() {
    super.initState();
    _callService = CallService();
    _setupCall();
  }

  Future<void> _setupCall() async {
    await _callService.initializeCall(isVideoCall: widget.isVideoCall);
    await _callService.joinChannel(widget.channelName);
    setState(() {});
  }

  @override
  void dispose() {
    _callService.leaveCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _callService,
      child: Consumer<CallService>(
        builder: (context, call, _) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Remote video / placeholder
                Center(
                  child: call.remoteUid != null && widget.isVideoCall
                      ? AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: call.engine!,
                            canvas: VideoCanvas(uid: call.remoteUid),
                            connection: RtcConnection(channelId: widget.channelName),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundColor: Color(0xFF128C7E),
                              child: Icon(Icons.person, size: 60, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.remoteUserName,
                              style: const TextStyle(color: Colors.white, fontSize: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              call.remoteUid == null ? 'Connect ho raha hai...' : 'Call par hai',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                ),
                // Local video preview (small box, top right)
                if (widget.isVideoCall && call.localUserJoined)
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: call.engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
                  ),
                // Controls
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _callButton(
                        icon: call.isMuted ? Icons.mic_off : Icons.mic,
                        onPressed: call.toggleMute,
                      ),
                      const SizedBox(width: 20),
                      _callButton(
                        icon: Icons.call_end,
                        color: Colors.red,
                        onPressed: () {
                          call.leaveCall();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 20),
                      if (widget.isVideoCall)
                        _callButton(
                          icon: call.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                          onPressed: call.toggleVideo,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _callButton({required IconData icon, required VoidCallback onPressed, Color? color}) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: color ?? Colors.white24,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
