import 'package:flutter/material.dart';

import '../widgets/intent_summary_card.dart';

/// Converts raw `extracted_fields` from the backend coordinator response
/// into a display-ready [IntentTileData] list for [IntentSummaryCard].
///
/// Never hardcodes service names, locations, or budget labels.
abstract final class IntentDisplayModel {
  /// Build tiles from a coordinator `extracted_fields` map.
  ///
  /// [fallbackLocation] is used only when the backend provides no location
  /// field (e.g. the user's profile area/city from [userProfileProvider]).
  static List<IntentTileData> tilesFromExtractedFields(
    Map<String, dynamic> fields, {
    String fallbackLocation = '',
  }) {
    final tiles = <IntentTileData>[];

    // ── 1. Service type ─────────────────────────────────────────────────────
    final serviceType =
        _str(fields, ['service_type', 'serviceType', 'service', 'category']);
    if (serviceType.isNotEmpty) {
      tiles.add(IntentTileData(
        title: _titleCase(serviceType),
        subtitle: _urgencyLabel(fields),
        icon: _serviceIcon(serviceType),
        bgColor: const Color(0xFFFDF2F2),
      ));
    }

    // ── 2. Location ─────────────────────────────────────────────────────────
    final location = _firstNonEmpty([
      _str(fields, ['location', 'area', 'location_address', 'address']),
      fallbackLocation,
    ]);
    if (location.isNotEmpty) {
      tiles.add(IntentTileData(
        title: location,
        icon: Icons.location_on,
        bgColor: const Color(0xFFF0F9F4),
      ));
    }

    // ── 3. Time preference ──────────────────────────────────────────────────
    final time = _str(fields, [
      'time_preference',
      'timePreference',
      'when',
      'scheduled_time',
      'time',
      'preferred_time',
    ]);
    if (time.isNotEmpty) {
      tiles.add(IntentTileData(
        title: time,
        icon: Icons.schedule,
        bgColor: const Color(0xFFF3F4F6),
      ));
    }

    // ── 4. Budget label ─────────────────────────────────────────────────────
    final budget = _str(fields, [
      'budget',
      'budget_label',
      'budgetLabel',
      'price_range',
      'price_sensitivity',
    ]);
    if (budget.isNotEmpty) {
      tiles.add(IntentTileData(
        title: _titleCase(budget),
        icon: Icons.savings_outlined,
        bgColor: const Color(0xFFFEF9F2),
      ));
    }

    return tiles;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static String _str(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return '';
  }

  static String _firstNonEmpty(List<String> values) {
    for (final v in values) {
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  static String _urgencyLabel(Map<String, dynamic> fields) {
    final u = _str(fields, ['urgency', 'urgency_level', 'priority']);
    if (u.isEmpty) return '';
    return '${_titleCase(u)} Urgency';
  }

  /// Title-case a snake_case or space-separated string.
  static String _titleCase(String s) => s
      .split(RegExp(r'[_\s]+'))
      .map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  /// Best-effort icon based on service type substring matching.
  static IconData _serviceIcon(String serviceType) {
    final t = serviceType.toLowerCase();
    if (t.contains('ac') || t.contains('air') || t.contains('cooling')) {
      return Icons.ac_unit;
    }
    if (t.contains('plumb') || t.contains('pipe') || t.contains('water')) {
      return Icons.plumbing;
    }
    if (t.contains('electric') || t.contains('wiring')) {
      return Icons.electrical_services;
    }
    if (t.contains('clean') || t.contains('wash')) {
      return Icons.cleaning_services;
    }
    if (t.contains('paint')) return Icons.format_paint;
    if (t.contains('carpen') || t.contains('wood') || t.contains('furniture')) {
      return Icons.carpenter;
    }
    if (t.contains('gas') || t.contains('heat')) return Icons.local_fire_department;
    if (t.contains('internet') || t.contains('wifi') || t.contains('network')) {
      return Icons.wifi;
    }
    return Icons.build_outlined;
  }
}
