import 'dart:async';

import 'package:command_runner/command_runner.dart';

class HelpCommand extends Command {
  HelpCommand() {
    addFlag(
      'verbose',
      abbr: 'v',
      help: 'When true, prints each command and its options.',
    );
    addOption(
      'command',
      abbr: 'c',
      help: 'Prints verbose usage for the specified command.',
    );
  }

  @override
  String get name => 'help';

  @override
  String get description => 'Prints usage information to the command line.';

  @override
  String? get help => 'Prints this usage information';

  @override
  FutureOr<String> run(ArgResults args) async {
    final buffer = StringBuffer();
    buffer.writeln(runner.usage.titleText);

    if (args.flag('verbose')) {
      for (var cmd in runner.commands) {
        buffer.write(_renderCommandVerbose(cmd));
      }

      return buffer.toString();
    }

    if (args.hasOption('command')) {
      var (:option, :input) = args.getOption('command');

      var cmd = runner.commands.firstWhere(
        (command) => command.name == input,
        orElse: () {
          throw ArgumentException('Input $input is not a known command.', name);
        },
      );

      return _renderCommandVerbose(cmd);
    }

    // Verbose is false and no arg was passed in, so print basic usage.
    for (var command in runner.commands) {
      buffer.writeln(command.usage);
    }

    return buffer.toString();
  }

  String _renderCommandVerbose(Command cmd) {
    final indent = ' ' * 10;
    final buffer = StringBuffer();
    buffer.writeln(cmd.usage.instructionText); //abbr, name: description
    buffer.writeln('$indent ${cmd.help}');
    if (cmd.valueHelp != null) {
      buffer.writeln(
        '$indent [Argument] Required? ${cmd.requiresArgument}, Type: ${cmd.valueHelp}, Default: ${cmd.defaultValue ?? 'none'}',
      );
    }
    buffer.writeln('$indent Options:');
    for (var option in cmd.options) {
      buffer.writeln('$indent ${option.usage}');
    }
    return buffer.toString();
  }
}
