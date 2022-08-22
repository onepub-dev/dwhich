A dwhich command-line application created by DCli.

The dwhich is an extended version of the classic 'which' command which  is designed to help you disagnose common PATH problems.

dwhich works on Linux, MacOS and Windows.

dwhich reports the following:
* multiple occurances of the command on your path
* if a command is found but not executable (posix only)
* duplicate PATH entries
* PATH entries where the directory no longer exists
* empty PATH entries.

Use the `-f` flag to revert dwhich to standard `which` style output.

```
dwhich --help

Locates a command on the PATH whilst validationg your PATH.

Description: 
                  searches the PATH environment variable for any directories 
                  that contains the passed command and prints those directory in the
                  order they appear in PATH.
                  As dwhich searches your PATH it also validates it checking for
                  common problems.

Usage:
which [-d][-f][-h][-v] <command>

-h, --help             Displays this usage message.
-v, --[no-]validate    Performs validation on the PATH environment variable
                       such as checking for:
                         * duplicates
                         * empty paths
                         * paths to non-existant directories
                       (defaults to on)
-f, --first            Restricts the output to the first path containing the command.

Exit Status:
                  0 - the command was found and exectuable, and the PATH was valid.
                  1 - the command was found and exectuable, but the PATH was invalid.
                  2 - the command was found but not exectuable, and the PATH was valid.
                  3 - the command was found but not exectuable, but the PATH was invalid.
                  4 - the command was not found but the PATH was valid.
                  5 - the command was not found and the PATH was valid.
                  6 - an invalid arguments were passed.
```