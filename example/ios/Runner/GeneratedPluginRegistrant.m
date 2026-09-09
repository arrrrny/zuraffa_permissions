//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

#if __has_include(<zuraffa_permissions_ios/ZuraffaPermissionsPlugin.h>)
#import <zuraffa_permissions_ios/ZuraffaPermissionsPlugin.h>
#else
@import zuraffa_permissions_ios;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
  [ZuraffaPermissionsPlugin registerWithRegistrar:[registry registrarForPlugin:@"ZuraffaPermissionsPlugin"]];
}

@end
