library pub_1290_lib.dal.transformer;

// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Code transform for @observable. The core transformation is relatively
/// straightforward, and essentially like an editor refactoring.

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:source_maps/refactor.dart';
import 'package:source_span/source_span.dart';

//import 'src/messages.dart';

class DALTransformer extends Transformer {
  final bool releaseMode;
  final List<String> _files;
  static int instance =0;
  DALTransformer([List<String> files, bool releaseMode])
      : _files = files,
        releaseMode = releaseMode == true{
    instance++;
  }
  DALTransformer.asPlugin(BarbackSettings settings)
      : _files = _readFiles(settings.configuration['files']),
        releaseMode = settings.mode == BarbackMode.RELEASE{
    instance++;
  }

  static List<String> _readFiles(value) {
    if (value == null) return null;
    var files = [];
    bool error;
    if (value is List) {
      files = value;
      error = value.any((e) => e is! String);
    } else if (value is String) {
      files = [value];
      error = false;
    } else {
      error = true;
    }
    if (error) print('Invalid value for "files" in the observe transformer.');
    return files;
  }

// TODO(nweiz): This should just take an AssetId when barback <0.13.0 support
// is dropped.
  Future<bool> isPrimary(idOrAsset) {
    var id = idOrAsset is AssetId ? idOrAsset : idOrAsset.id;
    return new Future.value(id.extension == '.dart' &&
        (_files == null || _files.contains(id.path)));
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) {
      // Do a quick string check to determine if this is this file even
      // plausibly might need to be transformed. If not, we can avoid an
      // expensive parse.

      if (!propertyMatcher.hasMatch(content)) return null;

      var id = transform.primaryInput.id;
      // TODO(sigmund): improve how we compute this url
      var url = id.path.startsWith('lib/')
          ? 'package:${id.package}/${id.path.substring(4)}'
          : id.path;
        transform.addOutput(transform.primaryInput);
    });
  }
}

final propertyMatcher =
    new RegExp("@(fetchProperty|persistProperty)|(Watcher\.)");