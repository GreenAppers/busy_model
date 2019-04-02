import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:scoped_model/scoped_model.dart';

class BusyModel extends Model {
  bool busy = false;
  String reason;
  double completed = 0;

  void setState(VoidCallback stateChangeCb) {
    stateChangeCb();
    notifyListeners();
  }

  void reset() {
    setState((){
      busy = false;
      reason = null;
      completed = 0;
    });
  }

  void setBusy(String why) {
    setState(() {
      busy = true;
      reason = why;
    });
  }
}

class BusyWidget extends StatelessWidget {
  final BusyModel model;
  BusyWidget(this.model);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 20.0,
        height: 20.0,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class BusyScope extends StatelessWidget {
  final BusyModel model;
  final Widget busy, child;

  BusyScope({
    @required this.model,
    @required this.busy,
    @required this.child
  });

  @override
  Widget build(BuildContext context) {
    return ScopedModel<BusyModel>(
      model: model,
      child: ScopedModelDescendant<BusyModel>(
        builder: (context, chld, cart) => BusySwitch(model, busy, child),
      ),
    );
  }
}

class BusySwitch extends StatelessWidget {
  final BusyModel model;
  final Widget busy, child;

  BusySwitch(this.model, this.busy, this.child);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: model.busy,
      child: Stack(
        children: <Widget>[
          child,
          model.busy ? busy : Container(width: 0, height: 0),
        ].where((Object o) => o != null).toList()
      ),
    );
  }
}
