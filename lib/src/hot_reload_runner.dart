import 'dart:async';
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';
import 'package:line_dot_dot/line_dot_dot.dart';

class HotReloadRunner {
  static Future<void> run(FutureOr<void> Function() func) async {
    late bool originalLineMode;
    try {
      originalLineMode = stdin.lineMode;
    } catch (_) {
      print(
          'Error: Cannot read stdin.lineMode. Try to run in an environment where command prompt input is available.');
      return;
    }
    stdin.lineMode = false;

    final reloader = await HotReloader.create();

    print('Starting...');
    await Future.sync(func);
    for (bool cont = true; cont;) {
      final readByte = String.fromCharCode(stdin.readByteSync());
      stdout.write('\r');
      switch (readByte) {
        case 'r':
          bool hotReloadError = false;
          final reloadResult = await CommandLineAnimation.lineDotDot(
            prompt: 'Reloading',
            future: reloader.reloadCode().onError((_, __) {
              print('Unexpected error. Try restarting your terminal.');
              hotReloadError = true;
              return HotReloadResult.Failed;
            }),
            promptSuffixOnFutureResult: (futureResult) => futureResult.name,
          );
          if (reloadResult == HotReloadResult.Succeeded) {
            await Future.sync(func);
          }
          if (hotReloadError) {
            cont = false;
          }
          break;
        case 'q':
          cont = false;
          break;
        default:
          continue;
      }
    }

    await CommandLineAnimation.lineDotDot(
      prompt: 'Leaving',
      donePromptSuffix: 'Bye',
      future: reloader.stop(),
    );

    stdin.lineMode = originalLineMode;
  }
}
