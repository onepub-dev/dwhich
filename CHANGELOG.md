# 2.0.2
- Check executable permissions through the native POSIX access API instead of
  running helpers found on the PATH being inspected.
- Escape terminal control characters in displayed paths and reject directories
  as command matches. Disable raw dependency debug logs during PATH lookup.
- Correct the Dart minimum to 3.10.1 and release-restoration constraints.

# 2.0.1
- upgraded all packages. lint fixes.

# 4.0.0
- upgraded to support dart 3.2 and above by removing the dcli components
that utilise waitfor.

# 2.0.0
- upgraded to support dart 3.x

# 1.0.4
- pinned the dependency versions so activation always works
even if an incompatible dependency has been published.

# 1.0.3
- upgraded to lates version of dcli.

# 1.0.2
= Added detection of the unsupported ~ in paths.
- removed \n's from pubspec description. 

# 1.0.1
Improvements in the documentation.

## 1.0.0

- Initial version.
