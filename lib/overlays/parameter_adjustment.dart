import 'package:flutter/material.dart';

class ParameterAdjustmentOverlay extends StatefulWidget {
  final Map<String, int> parameters;
  final int pointsRemaining;
  final int nextWave;

  final Function(String) onParameterIncrease;

  const ParameterAdjustmentOverlay({
    Key? key,
    required this.parameters,
    required this.pointsRemaining,
    required this.nextWave,
    required this.onParameterIncrease,
  }) : super(key: key);

  @override
  _ParameterAdjustmentOverlayState createState() =>
      _ParameterAdjustmentOverlayState();
}

class _ParameterAdjustmentOverlayState
    extends State<ParameterAdjustmentOverlay> {
  // パラメータ名とラベルの対応
  final Map<String, String> parameterLabels = {
    'separation': '分離',
    'alignment': '整列',
    'cohesion': '結束',
    'speed': '速度',
    'sight': '視野',
    'escape': '回避',
  };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withAlpha(200), // 背景色
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ボイドを強化しよう',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '次回Wave: ${widget.nextWave}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '残り ${widget.pointsRemaining} ポイント',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3, // 3列
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: widget.parameters.entries.map((entry) {
                final String label =
                    parameterLabels[entry.key] ?? entry.key; // 日本語ラベル
                return ElevatedButton(
                  onPressed: widget.pointsRemaining > 0
                      ? () => widget.onParameterIncrease(entry.key)
                      : null, // ポイントが残っていない場合は無効化
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // 角丸を設定
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 背景画像
                        Image.asset(
                          'assets/images/button/${entry.key}.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        // 暗い背景フィルター
                        Container(
                          color: Colors.white.withAlpha(200),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        // ラベルとレベル表示
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              label, // パラメータ名
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              'Lv: ${entry.value}', // 現在のレベル
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
