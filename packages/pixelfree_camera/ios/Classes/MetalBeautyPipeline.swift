import Foundation
import Metal
import CoreVideo

final class MetalBeautyPipeline {
  private let device: MTLDevice
  private let pipeline: MTLRenderPipelineState
  private let commandQueue: MTLCommandQueue
  private var textureCache: CVMetalTextureCache?

  init?(device: MTLDevice) {
    self.device = device
    guard let q = device.makeCommandQueue() else { return nil }
    commandQueue = q
    guard let library = device.makeDefaultLibrary(),
          let vs = library.makeFunction(name: "beauty_vs"),
          let fs = library.makeFunction(name: "beauty_fs") else { return nil }
    let desc = MTLRenderPipelineDescriptor()
    desc.vertexFunction = vs
    desc.fragmentFunction = fs
    desc.colorAttachments[0].pixelFormat = .bgra8Unorm
    do {
      pipeline = try device.makeRenderPipelineState(descriptor: desc)
    } catch {
      return nil
    }
    var cache: CVMetalTextureCache?
    CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
    textureCache = cache
  }

  /// Renders on the calling thread (waits for GPU) so [input] sample buffer stays valid.
  func render(
    input: CVPixelBuffer,
    output: CVPixelBuffer,
    brightness: Float,
    smoothing: Float,
    faceCenter: SIMD2<Float>,
    faceHalf: SIMD2<Float>,
    hasFace: Float
  ) {
    guard let cache = textureCache else {
      return
    }
    let iw = CVPixelBufferGetWidth(input)
    let ih = CVPixelBufferGetHeight(input)
    var cvTexIn: CVMetalTexture?
    CVMetalTextureCacheCreateTextureFromImage(
      kCFAllocatorDefault, cache, input, nil, .bgra8Unorm, iw, ih, 0, &cvTexIn
    )
    guard let cvIn = cvTexIn, let texIn = CVMetalTextureGetTexture(cvIn) else { return }

    let ow = CVPixelBufferGetWidth(output)
    let oh = CVPixelBufferGetHeight(output)
    var cvTexOut: CVMetalTexture?
    CVMetalTextureCacheCreateTextureFromImage(
      kCFAllocatorDefault, cache, output, nil, .bgra8Unorm, ow, oh, 0, &cvTexOut
    )
    guard let cvOut = cvTexOut, let texOut = CVMetalTextureGetTexture(cvOut) else { return }

    guard let cmd = commandQueue.makeCommandBuffer(),
          let pass = makePass(texture: texOut) else {
      return
    }

    let enc = cmd.makeRenderCommandEncoder(descriptor: pass)!
    enc.setRenderPipelineState(pipeline)
    enc.setFragmentTexture(texIn, index: 0)
    var b = brightness
    var sm = smoothing
    var fc = faceCenter
    var fh = faceHalf
    var hf = hasFace
    enc.setFragmentBytes(&b, length: MemoryLayout<Float>.size, index: 0)
    enc.setFragmentBytes(&sm, length: MemoryLayout<Float>.size, index: 1)
    enc.setFragmentBytes(&fc, length: MemoryLayout<SIMD2<Float>>.size, index: 2)
    enc.setFragmentBytes(&fh, length: MemoryLayout<SIMD2<Float>>.size, index: 3)
    enc.setFragmentBytes(&hf, length: MemoryLayout<Float>.size, index: 4)
    enc.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    enc.endEncoding()
    cmd.commit()
    cmd.waitUntilCompleted()
  }

  private func makePass(texture: MTLTexture) -> MTLRenderPassDescriptor? {
    let pass = MTLRenderPassDescriptor()
    pass.colorAttachments[0].texture = texture
    pass.colorAttachments[0].loadAction = .clear
    pass.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    pass.colorAttachments[0].storeAction = .store
    return pass
  }
}
