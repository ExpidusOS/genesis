//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
#include <expidus/expidus_plugin_c_api.h>
#include <miso/miso_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BitsdojoWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BitsdojoWindowPlugin"));
  ExpidusPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ExpidusPluginCApi"));
  MisoPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("MisoPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
