library pub_1290_lib.version.transformer;

// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Code transform for @observable. The core transformation is relatively
/// straightforward, and essentially like an editor refactoring.

import 'dart:async';

import 'package:barback/barback.dart';
import 'dart:io';

class VersionInjectorTransformer extends Transformer {
  final bool releaseMode;
  final List<String> _files;
  VersionInjectorTransformer([List<String> files, bool releaseMode])
  : _files = files,
    releaseMode = releaseMode == true;
  VersionInjectorTransformer.asPlugin(BarbackSettings settings)
  : _files = _readFiles(settings.configuration['files']),
  releaseMode = settings.mode == BarbackMode.RELEASE;

  //String get allowedExtensions => '.dart';

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
    print('$files');
    return files;
  }

  Future<bool> isPrimary(idOrAsset) {
    var id = idOrAsset is AssetId ? idOrAsset : idOrAsset.id;
    return new Future.value( _files.contains(id.path));
  }

  static const String VERSION_SAMPLE = '_%BUILD_VERSION%_';

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) {

      var version = Platform.environment["BUILD_NUMBER"];
      if (version == null || version =='') {
        version = "UNKNOWN";
      }
      var id = transform.primaryInput.id;

      transform.addOutput(new Asset.fromString(id, content.replaceAll(VERSION_SAMPLE,version)));
      transform.logger.info("Changed $id version: $version");
    });
  }
}