import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:interview_test_project/providers/channel_controller.dart';
import 'package:interview_test_project/providers/channels_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ChannelsProvider(channelCount: 10),)
    ],
    child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview Test Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DemoScreen()
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final channelsProvider = context.watch<ChannelsProvider>();
    final channels = channelsProvider.channels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Demo'),
        actions: [
          Center(
            child: Row(
              children: [
                const Text('All CH:  '),
                IconButton(
                  tooltip: 'Play All',
                  onPressed: channelsProvider.playAll,
                  icon: const Icon(Icons.play_circle_fill, color: Colors.green,)
                ),
                IconButton(
                    tooltip: 'Stop All',
                    onPressed: channelsProvider.stopAll,
                    icon: const Icon(Icons.stop_circle, color: Colors.red,)
                ),
                const SizedBox(width: 8,)
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          itemCount: channels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 兩欄
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2 // 調整卡片比例
          ),
          itemBuilder: (context, index) {
            final controller = channels[index];
            // 用 Provider 包起來，ChannelCard 內用 watch/select 重建
            return ChangeNotifierProvider<ChannelController>.value(
              value: controller,
              child: const ChannelCard(),
            );
          },
        ),
      ),
    );
  }
}

/// ---- 單一 Channel 卡片（用 Provider 取用該 Channel 狀態）----
class ChannelCard extends StatelessWidget {
  const ChannelCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChannelController>(); // 監聽該 CH
    final points = controller.points;
    final lastX = points.isNotEmpty ? points.last.x : 10.0;
    final minX = (lastX - 10.0).clamp(0.0, double.infinity);
    final maxX = lastX < 10.0 ? 10.0 : lastX;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  controller.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Play',
                  onPressed: controller.play,
                  icon: const Icon(Icons.play_circle_fill, color: Colors.green,)
                ),
                IconButton(
                    tooltip: 'Stop',
                    onPressed: controller.stop,
                    icon: const Icon(Icons.stop_circle, color: Colors.red,)
                )
              ],
            ),
            const SizedBox(height: 4,),
            // 圖表區
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: -1.0,
                  maxY: 1.0,
                  minX: minX,
                  maxX: maxX,
                  lineBarsData: [
                    LineChartBarData(
                      spots: points.isEmpty ? [const FlSpot(0, 0)] : points,
                      isCurved: false,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    horizontalInterval: 0.5,
                    verticalInterval: 1
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 0.5,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10),
                        )
                      )
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(0), // 秒
                          style: const TextStyle(fontSize: 10),
                        )
                      )
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      top: BorderSide(color: Colors.black12),
                      right: BorderSide(color: Colors.black12),
                      left: BorderSide(color: Colors.black12),
                      bottom: BorderSide(color: Colors.black12)
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear,
              )
            )
          ],
        ),
      ),
    );
  }
}
