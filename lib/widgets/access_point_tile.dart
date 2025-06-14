import 'package:expidus/expidus.dart' hide TextField;
import 'package:flutter/material.dart'
    show ExpansionTile, ListTileTheme, TextField;
import '../services.dart';

class AccessPointTile extends StatefulWidget {
  const AccessPointTile({super.key, required this.accessPoint});

  final NetworkAccessPoint accessPoint;

  @override
  State<AccessPointTile> createState() => _AccessPointTileState();
}

class _AccessPointTileState extends State<AccessPointTile> {
  String? psk;
  String? error;

  Future<void> _connect() async {
    final conn = widget.accessPoint.connections.length > 0
        ? widget.accessPoint.connections[0]
        : await widget.accessPoint.createConnection(
            widget.accessPoint.requiresAuth ? psk : null,
          );
    await widget.accessPoint.activateConnection(conn);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.accessPoint,
    builder: (context, _) =>
        (widget.accessPoint.requiresAuth &&
            widget.accessPoint.connections.length == 0)
        ? ExpansionTile(
            leading: Icon(widget.accessPoint.icon),
            title: Text(String.fromCharCodes(widget.accessPoint.ssid)),
            childrenPadding: const EdgeInsets.all(8),
            children: [
              if (error != null)
                Card(
                  child: Text(
                    error!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: Colors.red[400]),
                  ),
                ),
              Row(
                children: [
                  SizedBox(
                    width: 230,
                    child: TextField(
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          error = null;
                          psk = value;
                        });
                      },
                      onSubmitted: (_) {
                        if ((psk?.length ?? 0) > 8 && (psk?.length ?? 0) < 63) {
                          _connect().catchError((e) {
                            setState(() {
                              error = e.toString();
                            });
                          });
                        }
                      },
                    ),
                  ),
                  Button(
                    isActive: (psk?.length ?? 0) > 8 && (psk?.length ?? 0) < 63,
                    child: Icon(Icons.arrow_right),
                    onPressed: () {
                      _connect().catchError((e) {
                        setState(() {
                          error = e.toString();
                        });
                      });
                    },
                  ),
                ],
              ),
            ],
          )
        : ActionRow(
            start: Icon(widget.accessPoint.icon),
            title: String.fromCharCodes(widget.accessPoint.ssid),
            onActivated: () {
              _connect().catchError((e) {
                setState(() {
                  error = e.toString();
                });
              });
            },
          ),
  );
}
