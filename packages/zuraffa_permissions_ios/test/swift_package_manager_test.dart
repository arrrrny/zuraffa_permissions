import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Structural contract of the Swift Package Manager migration (#6):
/// the plugin ships `ios/zuraffa_permissions_ios/Package.swift` (what the
/// Flutter tool probes via `pluginSwiftPackageManifestPath`) with its native
/// sources under the SPM source layout, while the podspec keeps building the
/// same sources for CocoaPods consumers.
void main() {
  const packageName = 'zuraffa_permissions_ios';
  const sourcesDir = 'ios/$packageName/Sources/$packageName';
  const pluginSource = '$sourcesDir/SwiftZuraffaPermissionsPlugin.swift';

  test('ships a Package.swift manifest where the Flutter tool expects it', () {
    final manifest = File('ios/$packageName/Package.swift');
    expect(
      manifest.existsSync(),
      isTrue,
      reason: 'expected ${manifest.path} to exist',
    );
  });

  test('manifest declares the plugin package for iOS', () {
    final contents = File('ios/$packageName/Package.swift').readAsStringSync();
    expect(contents, contains('name: "$packageName"'));
    expect(contents, contains('.library(name: "zuraffa-permissions-ios"'));
    expect(contents, contains(".iOS(\"13.0\")"));
    expect(contents, contains('swift-tools-version: 5.9'));
  });

  test('manifest depends on the Flutter-injected FlutterFramework package', () {
    final contents = File('ios/$packageName/Package.swift').readAsStringSync();
    expect(contents, contains('path: "../FlutterFramework"'));
    expect(contents, contains('FlutterFramework'));
  });

  test('native sources live in the SPM source layout', () {
    expect(File(pluginSource).existsSync(), isTrue,
        reason: 'expected $pluginSource to exist');
  });

  test('legacy CocoaPods Classes/ layout is gone', () {
    expect(
      Directory('ios/Classes').existsSync(),
      isFalse,
      reason: 'ios/Classes must be migrated to $sourcesDir',
    );
  });

  test('podspec keeps CocoaPods consumers building from the SPM sources', () {
    final podspec = File('ios/$packageName.podspec').readAsStringSync();
    expect(podspec, contains('$packageName/Sources/$packageName/**/*'));
    expect(podspec, isNot(contains("'Classes/")));
    expect(podspec, contains("s.dependency 'Flutter'"));
    expect(podspec, contains(":ios, '13.0'"));
  });
}
