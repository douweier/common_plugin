
import Flutter
import UIKit

public class CommonPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, UIApplicationDelegate {
    private var eventSink: FlutterEventSink?

    /// 注册插件，设置 MethodChannel 和 EventChannel，并注册为应用委托
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "common_plugin", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "common_plugin/events", binaryMessenger: registrar.messenger())

        let instance = CommonPlugin()

        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)

        // 将插件注册为 UIApplicationDelegate
        registrar.addApplicationDelegate(instance)
    }


    /// 处理来自 Flutter 端的方法调用
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result(UIDevice.current.systemVersion)
        case "getInitialUrl":
            if let url = initialURL {
                result(url.absoluteString)
            } else {
                result(nil)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }


    /// 开始监听事件通道
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    /// 取消监听事件通道
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }


    private var initialURL: URL?

    /// 处理应用通过 URL 打开的请求
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // 如果应用是通过 URL 启动的，记录初始 URL
        if application.applicationState == .inactive || application.applicationState == .background {
            initialURL = url
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?(url.absoluteString)
            }
        } else {
            // 应用已经在前台，直接发送 URL
            eventSink?(url.absoluteString)
        }
        return true
    }

    /// 处理应用启动时的选项，捕获初始的 URL
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let url = launchOptions?[.url] as? URL {
            initialURL = url
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?(url.absoluteString)
            }
        }
        return true
    }
}