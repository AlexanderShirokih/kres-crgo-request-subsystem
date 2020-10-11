#include "include/window_control/window_control_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>

#include <flutter/plugin_registrar_windows.h>

#include <flutter/standard_method_codec.h>

namespace {

  class WindowControlPlugin: public flutter::Plugin {

    public: static void RegisterWithRegistrar(flutter::PluginRegistrarWindows * registrar);

    WindowControlPlugin();

    virtual~WindowControlPlugin();

    private:
      // Called when a method is called on this plugin's channel from Dart.
      void HandleMethodCall(
        const flutter::MethodCall < flutter::EncodableValue > & method_call,
          std::unique_ptr < flutter::MethodResult < flutter::EncodableValue >> result);
  };

  // static
  void WindowControlPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows * registrar) {
    auto channel =
      std::make_unique < flutter::MethodChannel < flutter::EncodableValue >> (
        registrar -> messenger(), "window_control", &
        flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique < WindowControlPlugin > ();

    channel -> SetMethodCallHandler([plugin_pointer = plugin.get()](
      const auto & call, auto result) {
      plugin_pointer -> HandleMethodCall(call, std::move(result));
    });

    registrar -> AddPlugin(std::move(plugin));
  }

  WindowControlPlugin::WindowControlPlugin() {}

  WindowControlPlugin::~WindowControlPlugin() {}

  void WindowControlPlugin::HandleMethodCall(
    const flutter::MethodCall < flutter::EncodableValue > & method_call,
      std::unique_ptr < flutter::MethodResult < flutter::EncodableValue >> result) {
    auto methodName = method_call.method_name();

    if (methodName.compare("closeWindow") == 0) {
      HWND hWnd = GetActiveWindow();
      SendMessage(hWnd, WM_CLOSE, 0, NULL);
      flutter::EncodableValue response(true);
      result -> Success( & response);
    } else if (methodName.compare("minWindow") == 0) {
      HWND hWnd = GetActiveWindow();
      ShowWindow(hWnd, SW_MINIMIZE);
      flutter::EncodableValue response(true);
      result -> Success( & response);
    } else if (methodName.compare("toogleMaxWindow") == 0) {
      HWND hWnd = GetActiveWindow();
      HWND hWndScreen = GetDesktopWindow();
      RECT window;
      RECT screen;

      GetWindowRect(hWnd, &window);
      GetWindowRect(hWndScreen, &screen);

      auto isMaximized =
        (window.left == screen.left) &&
        (window.right == screen.right) &&
        (window.top == screen.top);

       if(isMaximized) {
         ShowWindow(hWnd, SW_SHOWDEFAULT);
       }
       else {
        ShowWindow(hWnd, SW_SHOWMAXIMIZED);
//        RECT workArea;
//       	SystemParametersInfo( SPI_GETWORKAREA, 0, &workArea, 0);
//        SetWindowPos(hWnd, NULL, workArea.left, workArea.top, workArea.right, workArea.bottom, NULL);
       }

      flutter::EncodableValue response(true);
      result -> Success( & response);
    } else if (methodName.compare("startDrag") == 0) {
      HWND hWnd = GetActiveWindow();
      ReleaseCapture();
      SendMessage(hWnd, WM_SYSCOMMAND, SC_MOVE | HTCAPTION, 0);
      flutter::EncodableValue response(true);
      result -> Success( & response);
    } else {
      result -> NotImplemented();
    }
  }
} // namespace

void WindowControlPluginRegisterWithRegistrar(
  FlutterDesktopPluginRegistrarRef registrar) {
  WindowControlPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarManager::GetInstance() ->
    GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}