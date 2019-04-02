import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:scoped_model/scoped_model.dart';

// Lift up the "busy state" so that any descendent Widget may access
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

// Any descendent of BusyScope may alter or depend on the "busy state"
class BusyScope extends StatelessWidget {
  final BusyModel model;
  final Widget child;

  BusyScope({
    @required this.model,
    @required this.child
  });

  @override
  Widget build(BuildContext context) {
    return ScopedModel<BusyModel>(
      model: model,
      child: _BusyScope(child),
    );
  }
}

// A desecendent widget allows BusyScope to IgnorePointer high up the Widget tree
class _BusyScope extends StatelessWidget {
  final Widget child;
  _BusyScope(this.child);

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<BusyModel>(context, rebuildOnChange: true);
    return IgnorePointer(
      ignoring: model.busy,
      child: child
    );
  }
}

// While BusyModalBarrier may be lower down the Widget tree
class BusyModalBarrier extends StatelessWidget {
  final BusyModel model;
  final Widget child, progressIndicator;
  Color color;
  double opacity;
  bool dismissible;

  BusyModalBarrier({
    Key key,
    @required this.model,
    @required this.child,
    this.progressIndicator = const Center(child: CircularProgressIndicator()),
    this.color = Colors.grey,
    this.opacity = 0.3,
    this.dismissible = false,
  }) : assert(child != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        !model.busy ? null : Opacity(
          child: ModalBarrier(dismissible: dismissible, color: color),
          opacity: opacity,
        ),
        !model.busy ? null : progressIndicator,
      ].where((Object o) => o != null).toList()
    );
  }
}
