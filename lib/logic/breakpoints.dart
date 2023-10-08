import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter/widgets.dart';

final _breakpoints = {
  'large': Breakpoints.large,
  'medium': Breakpoints.medium,
  'small': Breakpoints.small,
};

String findActiveBreakpointName(BuildContext context) =>
  _breakpoints.map((k, v) => MapEntry(k, v.isActive(context)))
    .entries.singleWhere((kv) => kv.value, orElse: () => MapEntry('standard', true)).key;

Breakpoint findActiveBreakpoint(BuildContext context) {
  final name = findActiveBreakpointName(context);
  if (name == 'standard') return Breakpoints.standard;
  return _breakpoints[name] ?? Breakpoints.standard;
}
