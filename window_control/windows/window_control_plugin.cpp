#include "include/window_control/window_control_plugin.h"

#include <windows.h>

#include <flutter/method_result_functions.h>

#include <flutter/method_channel.h>

#include <flutter/plugin_registrar_windows.h>

#include <flutter/standard_method_codec.h>

namespace {

  class WindowControlPlugin: public flutter::Plugin {

    public: static void RegisterWithRegistrar(flutter::PluginRegistrarWindows * registrar);

    WindowControlPlugin(std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel);

    virtual~WindowControlPlugin();

    private:
      std::optional<LRESULT> HandleWinProcMessage(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam);

      std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> controlChannel;
  };

  // static
  void WindowControlPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows * registrar) {
    auto channel =
      std::make_unique <flutter::MethodChannel<flutter::EncodableValue>> (
        registrar -> messenger(), "window_control", &
        flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<WindowControlPlugin>(std::move(channel));

    registrar -> RegisterTopLevelWindowProcDelegate([pluginRef = plugin.get()]
    (HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return pluginRef->HandleWinProcMessage(hwnd, message, wparam, lparam);
    });
    registrar -> AddPlugin(std::move(plugin));
  }

  WindowControlPlugin::WindowControlPlugin
  (std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel):
   controlChannel(std::move(channel)) {}

  WindowControlPlugin::~WindowControlPlugin() {}

  std::optional<LRESULT> WindowControlPlugin::HandleWinProcMessage(
    HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {

        if(message == WM_CLOSE) {
            auto result_handler = std::make_unique<flutter::MethodResultFunctions<>>(
                [hwnd](const flutter::EncodableValue* result) {
                   bool shouldCloseWindow = std::get<bool>(*result);
                   if(shouldCloseWindow) {
                        PostMessage(hwnd, WM_DESTROY, NULL, NULL);
                   }
                 },
                    nullptr, nullptr);

            controlChannel->InvokeMethod("onWindowClosing", nullptr, std::move(result_handler));

            return std::optional<LRESULT>(0);
        }

        return std::optional<LRESULT>();
   }

} // namespace

void WindowControlPluginRegisterWithRegistrar(
  FlutterDesktopPluginRegistrarRef registrar) {
  WindowControlPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarManager::GetInstance() ->
    GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}