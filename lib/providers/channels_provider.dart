import 'package:flutter/cupertino.dart';

import 'channel_controller.dart';

class ChannelsProvider extends ChangeNotifier {
  ChannelsProvider({int channelCount = 10}) {
    _channels = List.generate(channelCount, (i) => ChannelController('CH${i + 1}'));
  }

  late final List<ChannelController> _channels;
  List<ChannelController> get channels => List.unmodifiable(_channels);

  void playAll() {
    for (final c in _channels) {
      c.play();
    }
  }

  void stopAll() {
    for (final c in _channels) {
      c.stop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final c in _channels) {
      c.dispose();
    }
  }
}