#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

// pin the versions so dwhich is stable in in the face of changing
// dependencies.
void main(List<String> args) {
  'dcli lock'.run;
}
