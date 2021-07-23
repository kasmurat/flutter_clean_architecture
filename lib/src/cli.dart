import 'dart:io';

import 'package:args/args.dart';

Future<void> run(List<String> args) async {
  var create = ArgParser();
  create.addOption('page', abbr: 'p', help: 'Creates page with given value.');

  var parser = ArgParser();
  parser.addCommand('create', create);
  parser.addFlag('help',
      abbr: 'h', help: 'Show this message and exit.', negatable: false);

  try {
    var results = parser.parse(args);

    if (results['help']) {
      if (results.command != null && results.command!.name == 'create') {
        printCreateCommandHelpContent(create);
        exit(0);
      } else {
        printDefaultHelpContent(parser);
        exit(0);
      }
    }

    if (results.command != null) {
      if (results.command!.name == 'create' &&
          results.command!['page'] != null) {
        await createPage(results.command?['page']);
        exit(0);
      } else if (results.command!.arguments.isEmpty) {
        await createDefaultArchitectureFolders();
        exit(0);
      } else {
        print('Missing or wrong arguments.\n');
        printDefaultHelpContent(parser);
        exit(2);
      }
    } else {
      print('Missing or wrong arguments.\n');
      printDefaultHelpContent(parser);
      exit(2);
    }
  } catch (e) {
    print(e);
    print('Missing or wrong arguments.\n');
    printDefaultHelpContent(parser);
    exit(2);
  }
}

Future<void> createDefaultArchitectureFolders() async {
  print('Creating Architecture Folders...');
  var dir = '${Directory.current.path}/lib/src/';

  await Future.wait([
    Directory('${dir}app/pages').create(recursive: true),
    Directory('${dir}app/widgets').create(recursive: true),
    Directory('${dir}app/utils').create(recursive: true),
    Directory('${dir}data/repositories').create(recursive: true),
    Directory('${dir}data/helpers').create(recursive: true),
    File('${dir}data/constants.dart').create(recursive: true),
    Directory('${dir}domain/entities').create(recursive: true),
    Directory('${dir}domain/usecases').create(recursive: true),
    Directory('${dir}domain/repositories').create(recursive: true),
  ]);

  print('Done.');
}

Future<void> createPage(String name) async {
  print('Creating page: $name');
  var dir = '${Directory.current.path}/lib/src/app/pages/${name}/${name}';

  await Future.wait([
    File('${dir}_presenter.dart').create(recursive: true).then((_) async {
      await File('${dir}_presenter.dart').writeAsString(presenterContent(name));
      print('Created Presenter.');
    }),
    File('${dir}_controller.dart').create(recursive: true).then((_) async {
      await File('${dir}_controller.dart')
          .writeAsString(controllerContent(name));
      print('Created Controller.');
    }),
    File('${dir}_view.dart').create(recursive: true).then((_) async {
      await File('${dir}_view.dart').writeAsString(viewContent(name));
      print('Created View.');
    }),
  ]);

  print('Done.');
}

String presenterContent(String name) {
  var pascalCaseName = convertToPascalCase(name);
  return '''
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

class ${pascalCaseName}Presenter extends Presenter {
  @override
  void dispose() {
    // TODO: implement dispose
  }
}
  ''';
}

String controllerContent(String name) {
  var pascalCaseName = convertToPascalCase(name);
  return '''
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '${name}_presenter.dart';

class ${pascalCaseName}Controller extends Controller {
  final ${pascalCaseName}Presenter _presenter;

  ${pascalCaseName}Controller() : _presenter = ${pascalCaseName}Presenter();

  @override
  void initListeners() {
    // TODO: implement initListeners
  }
}
  ''';
}

String viewContent(String name) {
  var pascalCaseName = convertToPascalCase(name);

  return '''
import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '${name}_controller.dart';

class ${pascalCaseName}View extends View {
  @override
  State<StatefulWidget> createState() {
    return _${pascalCaseName}ViewState(
      ${pascalCaseName}Controller(),
    );
  }
}

class _${pascalCaseName}ViewState extends ViewState<${pascalCaseName}View, ${pascalCaseName}Controller> {
  _${pascalCaseName}ViewState(${pascalCaseName}Controller controller) : super(controller);

  @override
  // TODO: implement view
  Widget get view => throw UnimplementedError();
}
  ''';
}

String convertToPascalCase(String text) {
  var finalText = '';
  var words = text.split('_');

  words.forEach((word) {
    finalText += word[0].toUpperCase() + word.substring(1, word.length);
  });

  return finalText;
}

void printDefaultHelpContent(ArgParser parser) {
  print('Command Line Interface For Flutter Clean Architecture Package\n');
  print(parser.usage + '\n');
  print('Commands:');
  print('    create  Creates architecture related folders and files.\n');
  print(
      "Run 'flutter pub run flutter_clean_architecture:cli <command> --help' to get more\ninformation about a command.");
}

void printCreateCommandHelpContent(ArgParser parser) {
  print('Command Line Interface For Flutter Clean Architecture Package\n');
  print('create  Creates architecture related folders and files.\n');
  print('Options:');
  print('    ' + parser.usage);
}
