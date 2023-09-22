import 'dart:async';
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';
import 'package:line_dot_dot/line_dot_dot.dart';

class HotReloadRunner {
  static Future<void> run(FutureOr<void> Function() func) async {
    final originalLineMode = stdin.lineMode;
    stdin.lineMode = false;

    final reloader = await HotReloader.create();

    print('Starting...');
    await Future.sync(func);
    for (bool cont = true; cont;) {
      final readByte = String.fromCharCode(stdin.readByteSync());
      stdout.write('\r');
      switch (readByte) {
        case 'r':
          final reloadResult = await CommandLineAnimation.lineDotDot(
            prompt: 'Reloading',
            future: reloader.reloadCode(),
            promptSuffixOnFutureResult: (futureResult) => futureResult.name,
          );
          if (reloadResult == HotReloadResult.Succeeded) {
            await Future.sync(func);
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
