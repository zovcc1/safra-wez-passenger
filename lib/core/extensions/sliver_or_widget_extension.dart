import 'package:flutter/material.dart';

extension SliverWrapperExtension on Widget {
  Widget sliverIf(bool? condition) {
    return condition ?? false ? SliverToBoxAdapter(child: this) : this;
  }
}
