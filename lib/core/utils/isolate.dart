import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

abstract class IsolateRepository {
  Future<dynamic> initIsolate(dynamic func, [dynamic data]);
}

class InBuiltIsolate implements IsolateRepository {
  @override
  Future<dynamic> initIsolate(dynamic func, [data]) async {
    return await compute(func, data);
  }
}

class FlutterIsolate implements IsolateRepository {
  @override
  Future<dynamic> initIsolate(func, [data]) {
    final isolate = Isolate.run(func);
    return isolate;
  }
}

class IsolateManager {
  IsolateRepository getIsolate({required String isolateType}) {
    switch (isolateType) {
      case "inbuilt":
        return InBuiltIsolate();
      case "custom":
        return FlutterIsolate();
      default:
        return InBuiltIsolate();
    }
  }
}
