import 'package:flutter/foundation.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

abstract final class AdsConfig {
  // These must be created for ScanFold in LevelPlay. Never reuse QA Genie IDs.
  static const enabled = false;
  static const appKey = '';
  static const rewardedUnitId = '';
  static const interstitialUnitId = '';
}

class AdsService {
  AdsService._();

  static final AdsService instance = AdsService._();
  bool _initialized = false;

  bool get initialized => _initialized;
  bool get configured =>
      AdsConfig.enabled &&
      AdsConfig.appKey.isNotEmpty &&
      AdsConfig.rewardedUnitId.isNotEmpty &&
      AdsConfig.interstitialUnitId.isNotEmpty;

  Future<void> initialize() async {
    if (!configured || _initialized) return;
    try {
      await LevelPlay.init(
        initRequest: LevelPlayInitRequest(appKey: AdsConfig.appKey, userId: ''),
        initListener: _InitListener(
          onSuccess: () => _initialized = true,
          onFailure: (error) => debugPrint(
            '[SCANFOLD][ADS] Init failed: ${error.errorCode} ${error.errorMessage}',
          ),
        ),
      );
    } catch (error) {
      debugPrint('[SCANFOLD][ADS] Init exception: $error');
    }
  }
}

class _InitListener implements LevelPlayInitListener {
  final VoidCallback onSuccess;
  final void Function(LevelPlayInitError error) onFailure;

  const _InitListener({required this.onSuccess, required this.onFailure});

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) => onSuccess();

  @override
  void onInitFailed(LevelPlayInitError error) => onFailure(error);
}
