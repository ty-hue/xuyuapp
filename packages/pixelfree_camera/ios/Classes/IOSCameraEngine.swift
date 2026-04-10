import AVFoundation
import Flutter
import Foundation
import Metal
import QuartzCore
import UIKit
import Vision

final class IOSCameraEngine: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  private let textureRegistry: FlutterTextureRegistry
  private let channel: FlutterMethodChannel
  private let previewTexture = PreviewFlutterTexture()
  private var textureId: Int64 = 0

  private let sessionQueue = DispatchQueue(label: "pixelfree.camera.session")
  private let session = AVCaptureSession()
  private var videoOutput: AVCaptureVideoDataOutput?
  private var device: AVCaptureDevice?
  private var metal: MetalBeautyPipeline?

  private let smoother = VisionFaceSmoother()

  private var ratio: String = "9:16"
  private var flashMode: String = "off"
  private var cameraId: Int = 1
  private var enableAudio = true
  private var enableScreenFlashForFront = true
  private var gifMaxDurationMs = 5000
  private var recordSpeedName = "normal"

  private var beautyBrightness: Float = 0
  private var beautySmoothing: Float = 0

  private var outputWidth = 720
  private var outputHeight = 1280
  private var outputPool: CVPixelBufferPool?

  private var faceOverlay: [String: Double] = [:]
  private var lastFaceState: (center: SIMD2<Float>, half: SIMD2<Float>, has: Float) =
    (SIMD2<Float>(0.5, 0.5), SIMD2<Float>(0.2, 0.28), 0)

  private var isRecording = false
  private var assetWriter: AVAssetWriter?
  private var videoInput: AVAssetWriterInput?
  private var adaptor: AVAssetWriterInputPixelBufferAdaptor?
  private var frameIndex: Int64 = 0
  private var outputURL: URL?
  /// 当前段录像是否应写入麦克风轨（由 [startRecordingToDocuments(enableAudio:)] 传入，与 init 解耦）。
  private var recordingSessionEnableAudio = false

  private var gifRemaining = 0
  private var gifDir: URL?
  private var gifFrameIndex = 0
  private var gifCompletion: ((String) -> Void)?

  /// Preview luma EMA 0...1 (BGRA), for flash auto — bright scene skips screen fill / torch.
  private var sceneLumaEma: Float = 0.45
  private var sceneLumaSampleCount = 0
  private static let autoFlashBrightThreshold: Float = 0.42
  /// Vision 人脸每 2 帧跑一次，减轻 CPU，Metal 仍每帧出图，观感更接近系统相机流畅度。
  private var previewVisionFrameIndex: Int = 0

  init(textureRegistry: FlutterTextureRegistry, channel: FlutterMethodChannel) {
    self.textureRegistry = textureRegistry
    self.channel = channel
    super.init()
  }

  func start(
    ratio: String,
    flashMode: String,
    cameraId: Int,
    enableAudio: Bool,
    enableScreenFlashForFront: Bool,
    gifMaxDurationMs: Int,
    recordSpeedProfile: String,
    completion: @escaping (Int64) -> Void
  ) {
    self.ratio = ratio
    self.flashMode = flashMode
    self.cameraId = cameraId
    self.enableAudio = enableAudio
    self.enableScreenFlashForFront = enableScreenFlashForFront
    self.gifMaxDurationMs = min(max(gifMaxDurationMs, 1000), 30_000)
    self.recordSpeedName = recordSpeedProfile

    sessionQueue.async {
      self.session.stopRunning()
      guard let dev = self.pickCamera(position: cameraId == 1 ? .front : .back) else {
        DispatchQueue.main.async { completion(self.textureId > 0 ? self.textureId : -1) }
        return
      }
      self.device = dev
      let format = self.pickFormat(device: dev, ratio: ratio)
      do {
        try dev.lockForConfiguration()
        dev.activeFormat = format
        try self.applyFlashTorchLocked(device: dev)
        dev.unlockForConfiguration()
      } catch {}

      if self.metal == nil, let mtl = MTLCreateSystemDefaultDevice(), let pipe = MetalBeautyPipeline(device: mtl) {
        self.metal = pipe
      }

      self.session.beginConfiguration()
      self.session.sessionPreset = .high
      for input in self.session.inputs { self.session.removeInput(input) }
      for output in self.session.outputs { self.session.removeOutput(output) }

      do {
        let input = try AVCaptureDeviceInput(device: dev)
        if self.session.canAddInput(input) { self.session.addInput(input) }
      } catch {
        self.session.commitConfiguration()
        DispatchQueue.main.async { completion(self.textureId > 0 ? self.textureId : -1) }
        return
      }

      let vo = AVCaptureVideoDataOutput()
      vo.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
      vo.alwaysDiscardsLateVideoFrames = true
      vo.setSampleBufferDelegate(self, queue: self.sessionQueue)
      if self.session.canAddOutput(vo) { self.session.addOutput(vo) }
      self.videoOutput = vo
      if let conn = vo.connection(with: .video) {
        conn.videoOrientation = .portrait
        if conn.isVideoMirroringSupported {
          conn.isVideoMirrored = dev.position == .front
        }
      }

      let po = AVCapturePhotoOutput()
      if self.session.canAddOutput(po) { self.session.addOutput(po) }

      self.session.commitConfiguration()

      let dims = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
      let w = Int(dims.width)
      let h = Int(dims.height)
      self.outputWidth = min(w, h)
      self.outputHeight = max(w, h)
      self.rebuildPool()
      self.sceneLumaEma = 0.45
      self.sceneLumaSampleCount = 0

      if self.textureId == 0 {
        self.textureId = self.textureRegistry.register(self.previewTexture)
      }
      self.session.startRunning()
      DispatchQueue.main.async { completion(self.textureId) }
    }
  }

  private func pickCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInWideAngleCamera],
      mediaType: .video,
      position: position,
    ).devices.first
  }

  private func pickFormat(device: AVCaptureDevice, ratio: String) -> AVCaptureDevice.Format {
    let target: CGFloat = ratio == "3:4" ? 3 / 4 : 9 / 16
    var best: AVCaptureDevice.Format?
    var bestArea = 0
    for f in device.formats {
      let d = CMVideoFormatDescriptionGetDimensions(f.formatDescription)
      let w = Int(d.width)
      let h = Int(d.height)
      let short = CGFloat(min(w, h))
      let long = CGFloat(max(w, h))
      let a = short / long
      if abs(a - target) < 0.04 {
        let area = w * h
        if area > bestArea {
          bestArea = area
          best = f
        }
      }
    }
    return best ?? device.activeFormat
  }

  private func rebuildPool() {
    outputPool = nil
    let attrs: [String: Any] = [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
      kCVPixelBufferWidthKey as String: outputWidth,
      kCVPixelBufferHeightKey as String: outputHeight,
      kCVPixelBufferIOSurfacePropertiesKey as String: [:] as [String: Any],
    ]
    var pool: CVPixelBufferPool?
    CVPixelBufferPoolCreate(nil, nil, attrs as CFDictionary, &pool)
    outputPool = pool
  }

  private func applyFlashTorchLocked(device: AVCaptureDevice) throws {
    guard device.hasTorch else { return }
    if device.position == .front { return }
    switch flashMode {
    case "on":
      try device.setTorchModeOn(level: 1.0)
    default:
      // auto：预览不常亮手电；真闪光由拍照管线决定
      device.torchMode = .off
    }
  }

  func setFlashMode(_ mode: String) {
    flashMode = mode
    sessionQueue.async {
      guard let d = self.device else { return }
      try? d.lockForConfiguration()
      try? self.applyFlashTorchLocked(device: d)
      d.unlockForConfiguration()
    }
  }

  /// Flutter 美颜 0..1；与 Android `BeautyFlutterScale` 一致（磨皮 / 美白上限与旧版 Flutter 低数值对齐）。
  private static let smoothingFlutterScale: Float = 0.36
  private static let whiteningFlutterScale: Float = 0.55

  func setBeauty(_ map: [String: Any]) {
    let wRaw = (map["whitening"] as? NSNumber)?.floatValue ?? 0
    let sRaw = (map["smoothing"] as? NSNumber)?.floatValue ?? 0
    let w = max(0, min(1, wRaw))
    let s = max(0, min(1, sRaw))
    beautyBrightness = w * IOSCameraEngine.whiteningFlutterScale * 0.12
    beautySmoothing = s * IOSCameraEngine.smoothingFlutterScale
  }

  func flipCamera() {
    cameraId = cameraId == 0 ? 1 : 0
    start(
      ratio: ratio,
      flashMode: flashMode,
      cameraId: cameraId,
      enableAudio: enableAudio,
      enableScreenFlashForFront: enableScreenFlashForFront,
      gifMaxDurationMs: gifMaxDurationMs,
      recordSpeedProfile: recordSpeedName,
    ) { _ in }
  }

  func setRatio(_ r: String) {
    start(
      ratio: r,
      flashMode: flashMode,
      cameraId: cameraId,
      enableAudio: enableAudio,
      enableScreenFlashForFront: enableScreenFlashForFront,
      gifMaxDurationMs: gifMaxDurationMs,
      recordSpeedProfile: recordSpeedName,
    ) { _ in }
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    if flashMode == "auto" {
      updateSceneLuma(from: pb)
    }
    previewVisionFrameIndex += 1
    if previewVisionFrameIndex % 2 == 0 {
      runVision(pixelBuffer: pb)
    }

    guard let pool = outputPool, let metal = metal else { return }
    var out: CVPixelBuffer?
    CVPixelBufferPoolCreatePixelBuffer(nil, pool, &out)
    guard let outputBuf = out else { return }

    metal.render(
      input: pb,
      output: outputBuf,
      brightness: beautyBrightness,
      smoothing: beautySmoothing,
      faceCenter: lastFaceState.center,
      faceHalf: lastFaceState.half,
      hasFace: lastFaceState.has,
    )

    previewTexture.pixelBuffer = outputBuf
    DispatchQueue.main.async {
      self.textureRegistry.textureFrameAvailable(self.textureId)
    }

    if isRecording {
      appendVideo(buffer: outputBuf)
    }
    if gifRemaining > 0, let data = jpegData(from: outputBuf) {
      writeGifFrame(data)
    }
  }

  private func updateSceneLuma(from pb: CVPixelBuffer) {
    CVPixelBufferLockBaseAddress(pb, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pb, .readOnly) }
    let w = CVPixelBufferGetWidth(pb)
    let h = CVPixelBufferGetHeight(pb)
    guard w > 0, h > 0, let base = CVPixelBufferGetBaseAddress(pb) else { return }
    let bpr = CVPixelBufferGetBytesPerRow(pb)
    let ptr = base.assumingMemoryBound(to: UInt8.self)
    let maxByte = bpr * h
    let x0 = w / 4
    let y0 = h / 4
    let cw = w / 2
    let ch = h / 2
    var sum: Double = 0
    var n = 0
    var yy = y0
    while yy < y0 + ch {
      var x = x0
      while x < x0 + cw {
        let o = yy * bpr + x * 4
        if o + 3 < maxByte {
          let b = Double(ptr[o])
          let g = Double(ptr[o + 1])
          let r = Double(ptr[o + 2])
          let luma = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
          sum += luma
          n += 1
        }
        x += 8
      }
      yy += 8
    }
    guard n > 0 else { return }
    let yNew = Float(sum / Double(n))
    sceneLumaEma = sceneLumaEma * 0.78 + yNew * 0.22
    sceneLumaSampleCount += 1
  }

  /// 与 Android `needsFrontScreenFlash` 一致：auto 仅画面偏暗且已有采样时补屏闪。
  private func needsFrontScreenFlash() -> Bool {
    guard device?.position == .front else { return false }
    guard enableScreenFlashForFront else { return false }
    switch flashMode {
    case "on": return true
    case "auto":
      return sceneLumaSampleCount >= 1 && sceneLumaEma < Self.autoFlashBrightThreshold
    default:
      return false
    }
  }

  private func runVision(pixelBuffer: CVPixelBuffer) {
    let orientation: CGImagePropertyOrientation = device?.position == .front ? .leftMirrored : .up
    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
    let req = VNDetectFaceLandmarksRequest { [weak self] request, _ in
      guard let self = self else { return }
      guard let face = (request.results as? [VNFaceObservation])?.first else {
        self.smoother.reset()
        self.lastFaceState = (SIMD2<Float>(0.5, 0.5), SIMD2<Float>(0.2, 0.28), 0)
        return
      }
      let box = face.boundingBox
      let cx = Float(box.midX)
      let cy = Float(1 - box.midY)
      let fw = Float(box.width)
      let fh = Float(box.height)
      let measured: [Float] = [
        cx, cy,
        cx, cy,
        fw, fh,
        cx, cy - fh * 0.25,
        cx, cy,
        0, 0,
      ]
      let now = Int64(CACurrentMediaTime() * 1_000_000_000)
      self.smoother.update(measured: measured, timestampNs: now)
      guard let pred = self.smoother.predict(timestampNs: now) else { return }
      let pcx = pred[0]
      let pcy = pred[1]
      let pfw = pred[4]
      let pfh = pred[5]
      let half = SIMD2<Float>(max(pfw * 0.55, 0.08), max(pfh * 0.55, 0.1))
      self.lastFaceState = (SIMD2<Float>(pcx, pcy), half, 1)

      DispatchQueue.main.async {
        self.faceOverlay = [
          "centerX": Double(pcx),
          "centerY": Double(pcy),
          "faceWidth": Double(pfw),
          "faceHeight": Double(pfh),
          "eyeCenterX": Double(pcx),
          "eyeCenterY": Double(pcy),
          "headTopX": Double(pcx),
          "headTopY": Double(pcy - Double(pfh) * 0.35),
          "rollDegrees": 0,
        ]
        self.channel.invokeMethod("onFaceOverlay", arguments: self.faceOverlay)
      }
    }
    try? handler.perform([req])
  }

  private func jpegData(from buffer: CVPixelBuffer) -> Data? {
    let ci = CIImage(cvPixelBuffer: buffer)
    let ctx = CIContext()
    guard let cg = ctx.createCGImage(ci, from: ci.extent) else { return nil }
    let ui = UIImage(cgImage: cg)
    return ui.jpegData(compressionQuality: 0.88)
  }

  private func appendVideo(buffer: CVPixelBuffer) {
    guard let input = videoInput, let ad = adaptor else { return }
    let mult: Double = {
      switch recordSpeedName {
      case "slow": return 2.0
      case "fast": return 0.5
      default: return 1.0
      }
    }()
    let step = CMTime(value: 1, timescale: 30)
    let scaled = CMTimeMultiplyByFloat64(step, multiplier: mult)
    let pts = CMTimeMultiply(scaled, multiplier: Int32(frameIndex))
    frameIndex += 1
    if input.isReadyForMoreMediaData {
      _ = ad.append(buffer, withPresentationTime: pts)
    }
  }

  func startRecordingToDocuments(enableAudio: Bool = true) throws {
    recordingSessionEnableAudio = enableAudio
    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let url = dir.appendingPathComponent("VID_\(Int(Date().timeIntervalSince1970)).mp4")
    outputURL = url
    frameIndex = 0
    let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
    let settings: [String: Any] = [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: outputWidth,
      AVVideoHeightKey: outputHeight,
    ]
    let inp = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    inp.expectsMediaDataInRealTime = true
    let ad = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: inp,
      sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
      ] as [String: Any],
    )
    if writer.canAdd(inp) { writer.add(inp) }
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)
    assetWriter = writer
    videoInput = inp
    adaptor = ad
    isRecording = true
  }

  func stopRecording(completion: @escaping (String) -> Void) {
    isRecording = false
    videoInput?.markAsFinished()
    assetWriter?.finishWriting {
      let path = self.outputURL?.path ?? ""
      self.assetWriter = nil
      self.videoInput = nil
      self.adaptor = nil
      completion(path)
    }
  }

  func takePhoto(completion: @escaping (String, Int, Int) -> Void) {
    sessionQueue.async {
      guard let pb = self.previewTexture.pixelBuffer else {
        DispatchQueue.main.async { completion("", 0, 0) }
        return
      }
      let pw = CVPixelBufferGetWidth(pb)
      let ph = CVPixelBufferGetHeight(pb)
      let needsFlash = self.needsFrontScreenFlash()
      if needsFlash {
        DispatchQueue.main.async {
          self.channel.invokeMethod("onFrontFlashHint", arguments: ["active": true, "intensity": 0.92])
        }
        Thread.sleep(forTimeInterval: 0.18)
      }
      guard let data = self.jpegData(from: pb) else {
        if needsFlash {
          DispatchQueue.main.async {
            self.channel.invokeMethod("onFrontFlashHint", arguments: ["active": false, "intensity": 0.0])
          }
        }
        DispatchQueue.main.async { completion("", 0, 0) }
        return
      }
      let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let url = dir.appendingPathComponent("IMG_\(Int(Date().timeIntervalSince1970)).jpg")
      try? data.write(to: url)
      if needsFlash {
        DispatchQueue.main.async {
          self.channel.invokeMethod("onFrontFlashHint", arguments: ["active": false, "intensity": 0.0])
        }
      }
      DispatchQueue.main.async { completion(url.path, pw, ph) }
    }
  }

  func captureGifFrames(durationMs: Int, fps: Int, completion: @escaping (String) -> Void) {
    sessionQueue.async {
      let dur = min(max(durationMs, 400), self.gifMaxDurationMs)
      let f = min(max(fps, 3), 15)
      let n = min(max(Int(Double(dur) / 1000.0 * Double(f)), 4), 60)
      let dir = FileManager.default.temporaryDirectory.appendingPathComponent("gif_burst_\(Int(Date().timeIntervalSince1970))", isDirectory: true)
      try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
      self.gifDir = dir
      self.gifFrameIndex = 0
      self.gifRemaining = n
      self.gifCompletion = completion
    }
  }

  private func writeGifFrame(_ data: Data) {
    guard let dir = gifDir else { return }
    let url = dir.appendingPathComponent(String(format: "f_%04d.jpg", gifFrameIndex))
    try? data.write(to: url)
    gifFrameIndex += 1
    gifRemaining -= 1
    if gifRemaining <= 0 {
      let path = dir.path
      gifDir = nil
      let done = gifCompletion
      gifCompletion = nil
      DispatchQueue.main.async {
        done?(path)
      }
    }
  }

  func setRecordSpeedProfile(_ name: String) {
    recordSpeedName = name
  }

  func previewBufferSize() -> [String: Int] {
    ["width": outputWidth, "height": outputHeight]
  }

  func getFaceOverlayMap() -> [String: Double]? {
    faceOverlay.isEmpty ? nil : faceOverlay
  }

  func dispose() {
    sessionQueue.async {
      self.session.stopRunning()
      if self.textureId != 0 {
        self.textureRegistry.unregisterTexture(self.textureId)
        self.textureId = 0
      }
    }
  }
}
