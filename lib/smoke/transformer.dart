library pub_1290_lib.smoke.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:smoke/codegen/recorder.dart';
import 'package:smoke/codegen/generator.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/src/dart_sdk.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:source_maps/refactor.dart';
import 'package:path/path.dart' as path;
import 'package:source_span/source_span.dart';

class InjectSmokeConfigVisitor extends GeneralizingAstVisitor {
  final TextEditTransaction code;
  InjectSmokeConfigVisitor(this.code);
  @override
  visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.toString() == "useGeneratedCode") {
      var arg0 = node.argumentList.arguments[0];
      code.edit(arg0.offset, arg0.offset, 'initSmoke()..addAll(');
      code.edit(arg0.end, arg0.end, ')');
    }
    return super.visitMethodInvocation(node);
  }
}

class SmokeTransformer extends Transformer with ResolverTransformer {
  final BarbackSettings settings;

  SmokeTransformer.asPlugin(this.settings) {
    resolvers = new Resolvers(dartSdkDirectory);
  }

  @override
  Future applyResolver(Transform transform, Resolver resolver) async {
      transform.addOutput(transform.primaryInput);
  }


  Future<bool> isPrimary(idOrAsset) {
    AssetId id = idOrAsset is AssetId ? idOrAsset : idOrAsset.id;
    return new Future.value(id.extension == '.dart'
               ||
            id.path == 'test/browser_all.dart' ||
            id.path == 'test/vm_all.dart' ||
            (id.path.startsWith('test') && id.path.endsWith('_test.dart'))
        ); }
}
