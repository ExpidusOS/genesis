//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>
#include <expidus/expidus_plugin.h>
#include <miso/miso_plugin.h>
#include <url_launcher_linux/url_launcher_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) bitsdojo_window_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BitsdojoWindowPlugin");
  bitsdojo_window_plugin_register_with_registrar(bitsdojo_window_linux_registrar);
  g_autoptr(FlPluginRegistrar) expidus_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ExpidusPlugin");
  expidus_plugin_register_with_registrar(expidus_registrar);
  g_autoptr(FlPluginRegistrar) miso_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MisoPlugin");
  miso_plugin_register_with_registrar(miso_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
}
