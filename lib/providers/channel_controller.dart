import 'dart:async';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

// 「通道時間」只在播放時前進，以確保 Stop 後再 Play 能無縫接續
class ChannelController extends ChangeNotifier {
  ChannelController(this.name);

  final String name;
  final List<FlSpot> _points = [];
  bool _isPlaying = false;
  Timer? _timer;

  // 牆鐘： 全域秒數(一直走)
  static final Stopwatch _wallClock = Stopwatch()..start();

  // 通道時間： 只在播放時前進
  double _accumulatedPlaySec = 0.0; // 停止時累積到此
  double? _resumeWallSec; // 本次播放起點對應的vmgoow鐘秒數(playing 時不為 null, 停止時歸零)

  bool get isPlaying => _isPlaying;
  List<FlSpot> get points => List.unmodifiable(_points);

  // 牆鐘目前秒
  double _nowWallSec() => _wallClock.elapsedMilliseconds / 1000.0;

  // 取得當下通道秒數： 停止時不變、播放時遞增
  double _channelTimeSec() {
    if (_resumeWallSec != null) {
      return _accumulatedPlaySec + (_nowWallSec() - _resumeWallSec!);
    } else {
      return _accumulatedPlaySec;
    }
  }

  // 取樣： 新增一個 sin 波資料點
  void _tick() {
    final t = _channelTimeSec(); // 用通道時間當 x 軸
    // Sin 波： ±1V, 週期 5 秒 -> ω = 2π/5(角頻率: 每秒走1/5圈)
    const period = 5.0;
    const omega = 2 * math.pi / period;
    final y = math.sin(omega * t); //math.sin() 在數學定義上： −1≤sin(x)≤1, 所以幅值 = 1

    _points.add(FlSpot(t, y));

    // 只保留最近 10 秒的資料
    final keepFrom = t - 10.0;
    while (_points.isNotEmpty && _points.first.x < keepFrom) {
      _points.removeAt(0);
    }

    notifyListeners();
  }

  void play() {
    if (_isPlaying) return;
    _isPlaying = true;

    // 記錄此次播放對應牆鐘起點
    _resumeWallSec ??= _nowWallSec();

    // 每 0.3 秒產出一個點
    _timer ??= Timer.periodic(const Duration(milliseconds: 300), (_) => _tick());
    notifyListeners();
  }

  void stop() {
    if (!_isPlaying) return;
    _isPlaying = false;

    // 將目前的通道時間結算進累積值, 並清除起點
    _accumulatedPlaySec = _channelTimeSec();
    _resumeWallSec = null;

    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}