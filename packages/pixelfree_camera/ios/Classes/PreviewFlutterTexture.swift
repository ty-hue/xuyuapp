import Flutter
import Foundation

final class PreviewFlutterTexture: NSObject, FlutterTexture {
  var pixelBuffer: CVPixelBuffer?

  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    guard let pb = pixelBuffer else { return nil }
    return Unmanaged.passRetained(pb)
  }
}
