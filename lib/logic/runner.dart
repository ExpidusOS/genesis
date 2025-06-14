import 'dart:io';

Future<Process> runComponent({
  required String component,
  String? monitor,
  String? initialRoute,
}) async {
  final proc = await Process.start(Platform.resolvedExecutable, [
    '--component',
    component,
    if (monitor != null) ...["--monitor", monitor!],
    if (initialRoute != null) ...["--initial-route", initialRoute!],
  ]);

  stdout.addStream(proc.stdout);
  stderr.addStream(proc.stderr);
  return proc;
}
