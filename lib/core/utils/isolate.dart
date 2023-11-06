import 'dart:async';
import 'package:flutter/foundation.dart';

abstract class IsolateRepository {
  Future<dynamic> initIsolate(
      FutureOr<dynamic> Function() computation, var data);
}

class InBuiltIsolate implements IsolateRepository {
  @override
  Future initIsolate(FutureOr<dynamic> Function() computation, data) async {
    return await compute(computation as ComputeCallback, data);
  }
}

class IsolateManager {
  IsolateRepository getIsolate({required String isolateType}) {
    switch (isolateType) {
      case "inbuilt":
        return InBuiltIsolate();
      case "custom":
        return InBuiltIsolate();
      default:
        return InBuiltIsolate();
    }
  }
}
