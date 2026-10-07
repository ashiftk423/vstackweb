import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vstackweb/models/site_models.dart';

void main() {
  final json = jsonDecode(File('assets/content/site_content.json').readAsStringSync()) as Map<String, dynamic>;
  final team = (json['team'] as List<dynamic>)
      .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  test('every employee ID is well-formed and unique', () {
    expect(() => TeamMember.validateEmployeeIds(team), returnsNormally);
  });

  test('employee IDs continue sequentially from VBS-OR-0001', () {
    final numbers = team.map((m) => int.parse(m.employeeId.split('-').last)).toList()..sort();
    expect(numbers.first, 1);
    for (var i = 0; i < numbers.length; i++) {
      expect(numbers[i], i + 1, reason: 'Missing or skipped ID near VBS-OR-${(i + 1).toString().padLeft(4, '0')}');
    }
  });

  test('Ashif Saheer holds VBS-OR-0001', () {
    expect(team.firstWhere((m) => m.employeeId == 'VBS-OR-0001').id, 'ashif');
  });
}
