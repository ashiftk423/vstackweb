import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vstackweb/data/local_content_loader.dart';
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

  test('employee numbers continue sequentially from 0001', () {
    final numbers = team.map((m) => TeamMember.employeeNumber(m.employeeId)!).toList()..sort();
    expect(numbers.first, 1);
    for (var i = 0; i < numbers.length; i++) {
      expect(numbers[i], i + 1, reason: 'Missing or skipped employee number ${(i + 1).toString().padLeft(4, '0')}');
    }
  });

  test('department code matches each member', () {
    for (final m in team) {
      final code = m.employeeId.split('-')[1];
      final expected = m.role.contains('Co-Founder')
          ? 'OR'
          : switch (m.department) {
              'Digital Marketing' => 'DM',
              'Programming' => 'PD',
              _ => code,
            };
      expect(code, expected, reason: '${m.name} (${m.department}) has ${m.employeeId}');
    }
  });

  test('Ashif Saheer holds VBS-OR-0001', () {
    expect(team.firstWhere((m) => m.employeeId == 'VBS-OR-0001').id, 'ashif');
  });

  test('old card IDs still resolve by employee number', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final content = await LocalContentLoader.load();
    expect(content.memberByEmployeeId('VBS-OR-0004')?.employeeId, 'VBS-PD-0004');
    expect(content.memberFromScan('https://vstackbusinesssolutions.com/team/VBS-OR-0007')?.employeeId, 'VBS-DM-0007');
  });
}
