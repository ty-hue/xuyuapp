import Flutter
import UIKit

public class PixelfreeCameraPlugin: NSObject, FlutterPlugin {
  private var textureRegistry: FlutterTextureRegistry?
  private var cameraChannel: FlutterMethodChannel?
  private var engine: IOSCameraEngine?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.pixelfree.camera", binaryMessenger: registrar.messenger())
    let instance = PixelfreeCameraPlugin()
    instance.textureRegistry = registrar.textures()
    instance.cameraChannel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let registry = textureRegistry, let channel = cameraChannel else {
      result(FlutterError(code: "NO_REGISTRY", message: "Plugin not ready", details: nil))
      return
    }

    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "initCamera":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "initCamera expects a map", details: nil))
        return
      }
      let ratio = args["ratio"] as? String ?? "9:16"
      let flashMode = args["flashMode"] as? String ?? "off"
      let cameraId = args["cameraId"] as? Int ?? 1
      let enableAudio = args["enableAudio"] as? Bool ?? true
      let enableScreenFlashForFront = args["enableScreenFlashForFront"] as? Bool ?? true
      let gifMaxDurationMs = args["gifMaxDurationMs"] as? Int ?? 5000
      let recordSpeedProfile = args["recordSpeedProfile"] as? String ?? "normal"

      engine?.dispose()
      let eng = IOSCameraEngine(textureRegistry: registry, channel: channel)
      engine = eng

      eng.start(
        ratio: ratio,
        flashMode: flashMode,
        cameraId: cameraId,
        enableAudio: enableAudio,
        enableScreenFlashForFront: enableScreenFlashForFront,
        gifMaxDurationMs: gifMaxDurationMs,
        recordSpeedProfile: recordSpeedProfile,
      ) { tid in
        result(Int(tid))
      }

    case "getPreviewBufferSize":
      result(engine?.previewBufferSize())

    case "getInputGlTextureId":
      result(-1)

    case "setRatio":
      let r = (call.arguments as? [String: Any])?["ratio"] as? String ?? "9:16"
      engine?.setRatio(r)
      result(nil)

    case "setFlashMode":
      let mode = (call.arguments as? [String: Any])?["mode"] as? String ?? "off"
      engine?.setFlashMode(mode)
      result(nil)

    case "flipCamera":
      engine?.flipCamera()
      result(nil)

    case "setBeauty":
      let m = call.arguments as? [String: Any] ?? [:]
      engine?.setBeauty(m)
      result(nil)

    case "setFilter", "setSticker", "setArEffect":
      result(nil)

    case "setRecordSpeedProfile":
      let name = (call.arguments as? [String: Any])?["profile"] as? String ?? "normal"
      engine?.setRecordSpeedProfile(name)
      result(nil)

    case "captureGifFrames":
      let durationMs = (call.arguments as? [String: Any])?["durationMs"] as? Int ?? 3000
      let fps = (call.arguments as? [String: Any])?["fps"] as? Int ?? 10
      engine?.captureGifFrames(durationMs: durationMs, fps: fps) { path in
        result(path)
      }

    case "getFaceOverlay":
      result(engine?.getFaceOverlayMap())

    case "getFaceAlignmentDebug":
      result(nil)

    case "takePhoto":
      if let eng = engine {
        eng.takePhoto { path, pixelW, pixelH in
          var payload: [String: Any] = [
            "path": "",
            "pixelWidth": pixelW,
            "pixelHeight": pixelH,
          ]
          if !path.isEmpty {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: url) {
              payload["jpegBytes"] = FlutterStandardTypedData(bytes: data)
            }
            try? FileManager.default.removeItem(at: url)
          }
          result(payload)
        }
      } else {
        result([
          "path": "",
          "pixelWidth": 0,
          "pixelHeight": 0,
        ])
      }

    case "startRecord":
      let enableAudio = (call.arguments as? [String: Any])?["enableAudio"] as? Bool ?? true
      do {
        try engine?.startRecordingToDocuments(enableAudio: enableAudio)
        result(nil)
      } catch {
        result(FlutterError(code: "RECORD", message: error.localizedDescription, details: nil))
      }

    case "stopRecord":
      engine?.stopRecording { path in
        result(path)
      }

    case "releaseCamera":
      engine?.dispose()
      engine = nil
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
