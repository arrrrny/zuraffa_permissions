# zuraffa_permissions_platform_interface

The platform interface contract for [`zuraffa_permissions`](https://pub.dev/packages/zuraffa_permissions):
the MethodChannel protocol and the `PermissionPort` bridge that endorsed
platform implementations conform to.

## Usage

This package is [endorsed](https://docs.flutter.dev/packages-and-plugins/developing-packages#endorsed-federated-plugin)
by the platform implementations and is pulled in automatically when you
depend on `zuraffa_permissions`. You should not need to depend on it
directly.

To implement the contract for an unsupported platform, extend
`PermissionPlatformInterface` and register your factory — the typed
`PermissionPort` seam (`request`/`check`/`openSettings` per scope) is the
whole surface.

See the main [zuraffa_permissions](https://pub.dev/packages/zuraffa_permissions)
package for full documentation.
