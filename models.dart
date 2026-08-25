import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AnalysisPreferences {
  static const _currentKey = 'analysis_preferences_v4';
  static const _presetsKey = 'analysis_presets_v4';

  final double minOpportunity;
  final double minAnomaly;
  final double maxAnomaly;
  final double minConfidence;
  final double maxValueTrap;
  final int topN;
  final int scanLimit;
  final int catalystTopN;
  final bool simpleMode;
  final String market;
  final String companySize;
  final String riskProfile;
  final List<String> sectors;
  final double minValuation;
  final double minDrawdownPct;
  final int minAverageVolume;
  final String eventFilter;

  const AnalysisPreferences({
    this.minOpportunity = 0,
    this.minAnomaly = 60,
    this.maxAnomaly = 100,
    this.minConfidence = 0,
    this.maxValueTrap = 100,
    this.topN = 30,
    this.scanLimit = 300,
    this.catalystTopN = 120,
    this.simpleMode = true,
    this.market = 'global',
    this.companySize = 'all',
    this.riskProfile = 'balanced',
    this.sectors = const [],
    this.minValuation = 0,
    this.minDrawdownPct = 0,
    this.minAverageVolume = 0,
    this.eventFilter = 'all',
  });

  AnalysisPreferences copyWith({
    double? minOpportunity,
    double? minAnomaly,
    double? maxAnomaly,
    double? minConfidence,
    double? maxValueTrap,
    int? topN,
    int? scanLimit,
    int? catalystTopN,
    bool? simpleMode,
    String? market,
    String? companySize,
    String? riskProfile,
    List<String>? sectors,
    double? minValuation,
    double? minDrawdownPct,
    int? minAverageVolume,
    String? eventFilter,
  }) {
    return AnalysisPreferences(
      minOpportunity: minOpportunity ?? this.minOpportunity,
      minAnomaly: minAnomaly ?? this.minAnomaly,
      maxAnomaly: maxAnomaly ?? this.maxAnomaly,
      minConfidence: minConfidence ?? this.minConfidence,
      maxValueTrap: maxValueTrap ?? this.maxValueTrap,
      topN: topN ?? this.topN,
      scanLimit: scanLimit ?? this.scanLimit,
      catalystTopN: catalystTopN ?? this.catalystTopN,
      simpleMode: simpleMode ?? this.simpleMode,
      market: market ?? this.market,
      companySize: companySize ?? this.companySize,
      riskProfile: riskProfile ?? this.riskProfile,
      sectors: sectors ?? this.sectors,
      minValuation: minValuation ?? this.minValuation,
      minDrawdownPct: minDrawdownPct ?? this.minDrawdownPct,
      minAverageVolume: minAverageVolume ?? this.minAverageVolume,
      eventFilter: eventFilter ?? this.eventFilter,
    );
  }

  Map<String, dynamic> toJson() => {
        'minOpportunity': minOpportunity,
        'minAnomaly': minAnomaly,
        'maxAnomaly': maxAnomaly,
        'minConfidence': minConfidence,
        'maxValueTrap': maxValueTrap,
        'topN': topN,
        'scanLimit': scanLimit,
        'catalystTopN': catalystTopN,
        'simpleMode': simpleMode,
        'market': market,
        'companySize': companySize,
        'riskProfile': riskProfile,
        'sectors': sectors,
        'minValuation': minValuation,
        'minDrawdownPct': minDrawdownPct,
        'minAverageVolume': minAverageVolume,
        'eventFilter': eventFilter,
      };

  factory AnalysisPreferences.fromJson(Map<String, dynamic> json) {
    return AnalysisPreferences(
      minOpportunity: (json['minOpportunity'] as num?)?.toDouble() ?? 0,
      minAnomaly: (json['minAnomaly'] as num?)?.toDouble() ?? 60,
      maxAnomaly: (json['maxAnomaly'] as num?)?.toDouble() ?? 100,
      minConfidence: (json['minConfidence'] as num?)?.toDouble() ?? 0,
      maxValueTrap: (json['maxValueTrap'] as num?)?.toDouble() ?? 100,
      topN: (json['topN'] as num?)?.toInt() ?? 30,
      scanLimit: (json['scanLimit'] as num?)?.toInt() ?? 300,
      catalystTopN: (json['catalystTopN'] as num?)?.toInt() ?? 120,
      simpleMode: json['simpleMode'] != false,
      market: json['market']?.toString() ?? 'global',
      companySize: json['companySize']?.toString() ?? 'all',
      riskProfile: json['riskProfile']?.toString() ?? 'balanced',
      sectors: ((json['sectors'] ?? []) as List)
          .map((item) => item.toString())
          .toList(),
      minValuation: (json['minValuation'] as num?)?.toDouble() ?? 0,
      minDrawdownPct:
          (json['minDrawdownPct'] as num?)?.toDouble() ?? 0,
      minAverageVolume:
          (json['minAverageVolume'] as num?)?.toInt() ?? 0,
      eventFilter: json['eventFilter']?.toString() ?? 'all',
    );
  }

  static Future<AnalysisPreferences> load() async {
    final storage = await SharedPreferences.getInstance();
    final encoded = storage.getString(_currentKey);
    if (encoded == null || encoded.isEmpty) {
      return const AnalysisPreferences();
    }
    try {
      return AnalysisPreferences.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
    } catch (_) {
      return const AnalysisPreferences();
    }
  }

  Future<void> save() async {
    final storage = await SharedPreferences.getInstance();
    await storage.setString(_currentKey, jsonEncode(toJson()));
  }

  static Future<Map<String, AnalysisPreferences>> loadPresets() async {
    final storage = await SharedPreferences.getInstance();
    final encoded = storage.getString(_presetsKey);
    if (encoded == null || encoded.isEmpty) return {};
    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return decoded.map(
        (name, value) => MapEntry(
          name,
          AnalysisPreferences.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> savePreset(String name) async {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return;
    final presets = await loadPresets();
    presets[cleaned] = this;
    final storage = await SharedPreferences.getInstance();
    await storage.setString(
      _presetsKey,
      jsonEncode(presets.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }

  static Future<void> deletePreset(String name) async {
    final presets = await loadPresets();
    presets.remove(name);
    final storage = await SharedPreferences.getInstance();
    await storage.setString(
      _presetsKey,
      jsonEncode(presets.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }
}
