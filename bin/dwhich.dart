#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dwhich/src/args.dart';
import 'package:dwhich/src/exit_exception.dart';
import 'package:path/path.dart';
import 'package:posix/posix.dart' as posix;

/// dwhich appname - searches for 'appname' on the path
void main(List<String> cliArgs) {
  final Args args;
  var found = false;
  var exectuable = false;

  try {
    args = Args.parse(cliArgs);

    // DCLI verbose logs raw PATH values before this CLI can escape them.
    Settings().setVerbose(enabled: false);
    if (args.debug) {
      printerr('Raw dependency debug logging is disabled for PATH lookups.');
    }

    // validation(args, () => 'Path: ${env['PATH']}');

    final paths = dedupPaths(args);

    String? priorPath;

    for (final path in paths) {
      // validation(args, () => 'Searching: ${truepath(path)}');
      if (!validatePath(path, args, priorPath)) {
        continue;
      }

      final pathToCmd = containsCommand(truepath(path, args.command));
      if (pathToCmd != null) {
        found = true;
        if (!isExecutableCommand(pathToCmd)) {
          print(
              'Found at: ${safeDisplay(pathToCmd)} but it is not executable.');
          continue;
        }
        exectuable = true;

        print('Found at: ${safeDisplay(pathToCmd)}');

        // found an exectuable.
        if (args.first) {
          break;
        }
      }
      priorPath = path;
    }
  } on ExitException catch (e) {
    printerr(red(safeDisplay(e.message)));
    if (e.exitCode == ExitException.invalidArgs) {
      Args.showUsage();
    }
    exit(e.exitCode);
  }
  final goodPath = printProblems(args);

  exit(ExitException.mapExitCode(
      found: found, exectuable: exectuable, goodPath: goodPath));
}

bool validatePath(String path, Args args, String? lastPath) {
  var valid = true;
  // validation(args, () => 'Searching: ${truepath(path)}');
  if (path.isEmpty) {
    validation(args, () => 'Empty path found');
    if (Platform.isLinux) {
      path = '.';

      /// current
      validation(
          args,
          () => orange('WARNING: current directory is on your path due '
              'to an empty path '
              '${lastPath == null ? '' : 'after ${safeDisplay(lastPath)}'} .'));
    } else {
      validation(args, () => red('''
Found empty path ${lastPath == null ? '' : 'after ${safeDisplay(lastPath)}'}.'''));
      valid = false;
    }
  }

  if (valid && !exists(path)) {
    validation(
        args, () => red('The path ${safeDisplay(path)} does not exist.'));

    if (path.contains('~')) {
      validation(
          args,
          () => red(
              'The path ${safeDisplay(path)} contains an unsupported tilde. '
              'Replace it with a literal home directory path.'));
    }

    valid = false;
  }
  return valid;
}

/// Returns true if there we no problems dectected with PATH
bool printProblems(Args args) {
  if (problems.isNotEmpty) {
    print('');
    print(orange('Problems:'));
    for (final problem in problems) {
      printerr('    ${orange(problem)}');
    }
  }
  return problems.isEmpty;
}

/// reports any duplicate path entries.
Set<String> dedupPaths(Args args) {
  final paths = <String>{};

  for (final path in PATH) {
    if (paths.contains(path)) {
      validation(args,
          () => orange('Found duplicated path: ${safeDisplay(path)} in PATH'));
    } else {
      paths.add(path);
    }
  }
  return paths;
}

String? containsCommand(String cmd) {
  if (!Platform.isWindows || extension(cmd).isNotEmpty) {
    return FileSystemEntity.typeSync(cmd) == FileSystemEntityType.file
        ? cmd
        : null;
  }

  for (final ext in (env['PATHEXT'] ?? '.COM;.EXE;.BAT;.CMD').split(';')) {
    final fullCmd = '$cmd$ext';
    if (FileSystemEntity.typeSync(fullCmd) == FileSystemEntityType.file) {
      return fullCmd;
    }
  }
  return null;
}

/// Checks the selected file without running helpers found on PATH.
bool isExecutableCommand(String path) {
  if (FileSystemEntity.typeSync(path) != FileSystemEntityType.file) {
    return false;
  }
  if (Platform.isWindows) {
    return true;
  }
  return posix.access(path, posix.X_OK) == 0;
}

/// Make untrusted filenames and PATH values unambiguous in terminal output.
String safeDisplay(String value) {
  final output = StringBuffer();
  for (final rune in value.runes) {
    if (rune == 10) {
      output.write(r'\n');
    } else if (rune == 13) {
      output.write(r'\r');
    } else if (rune == 9) {
      output.write(r'\t');
    } else if (rune < 32 ||
        (rune >= 0x7f && rune <= 0x9f) ||
        rune == 0x200e ||
        rune == 0x200f ||
        (rune >= 0x202a && rune <= 0x202e) ||
        (rune >= 0x2066 && rune <= 0x2069)) {
      output.write('\\u{${rune.toRadixString(16)}}');
    } else {
      output.writeCharCode(rune);
    }
  }
  return output.toString();
}

final problems = <String>[];
void validation(Args args, String Function() message) {
  if (args.validate) {
    problems.add(message());
  }
}
