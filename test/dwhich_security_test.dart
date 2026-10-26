import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../bin/dwhich.dart' as dwhich;

void main() {
  test('terminal controls in paths are displayed as text', () {
    expect(
      dwhich.safeDisplay('bad\nline\u001b[2J\u202e'),
      r'bad\nline\u{1b}[2J\u{202e}',
    );
  });

  test('directories are never command matches', () {
    final directory = Directory.systemTemp.createTempSync('dwhich directory ');
    addTearDown(() => directory.deleteSync(recursive: true));
    expect(dwhich.containsCommand(directory.path), isNull);
    expect(dwhich.isExecutableCommand(directory.path), isFalse);
  });

  test('lookup does not execute groups from the inspected PATH', () {
    if (Platform.isWindows) {
      return;
    }
    final directory = Directory.systemTemp.createTempSync('dwhich path ');
    addTearDown(() => directory.deleteSync(recursive: true));
    final candidate = File(path.join(directory.path, 'probe'))
      ..writeAsStringSync('not executed');
    final chmod = Process.runSync('chmod', ['750', candidate.path]);
    expect(chmod.exitCode, 0);
    Link(path.join(directory.path, 'groups')).createSync('/usr/bin/false');

    final packageConfig = File('.dart_tool/package_config.json').absolute.path;
    final result = Process.runSync(
      Platform.resolvedExecutable,
      ['--packages=$packageConfig', 'bin/dwhich.dart', '--first', 'probe'],
      environment: {'PATH': '${directory.path}:/usr/bin:/bin'},
      workingDirectory: Directory.current.path,
    );

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout as String, contains('Found at: ${candidate.path}'));
  });

  test('debug lookup does not print raw PATH control characters', () {
    final packageConfig = File('.dart_tool/package_config.json').absolute.path;
    final injectedPath =
        '${Directory.systemTemp.path}/missing\nFORGED\u001b[2J';
    final result = Process.runSync(
      Platform.resolvedExecutable,
      [
        '--packages=$packageConfig',
        'bin/dwhich.dart',
        '--debug',
        '--validate',
        'definitely_missing',
      ],
      environment: {'PATH': '$injectedPath:/usr/bin:/bin'},
      workingDirectory: Directory.current.path,
    );

    final output = '${result.stdout}${result.stderr}';
    expect(output, contains(r'\nFORGED\u{1b}[2J'));
    expect(output, isNot(contains('\nFORGED')));
    expect(output, isNot(contains('\u001b[2J')));
  });
}
