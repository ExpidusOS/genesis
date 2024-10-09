import 'package:expidus/expidus.dart';

class ActionDialog extends StatelessWidget {
  const ActionDialog({super.key});

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: Text('Application Selection'),
      );
}
