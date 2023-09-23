import 'package:hot_reload_runner/hot_reload_runner.dart';

void printSomething() {
  print('hello hot reload');
}

void main() async {
  HotReloadRunner.run(printSomething);
}
