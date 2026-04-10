import Foundation
import Vision

/// 2D Kalman-style smoothing for Vision face landmarks (same gains as Android MediaPipe Kalman).
final class VisionFaceSmoother {
  private var state: [Float]?
  private var velocity: [Float]?
  private var lastUpdateNs: Int64 = 0
  private var initialized = false

  private let dim = 12

  func reset() {
    state = nil
    velocity = nil
    initialized = false
    lastUpdateNs = 0
  }

  func update(measured: [Float], timestampNs: Int64) {
    guard measured.count >= dim else { return }
    if !initialized || state == nil {
      state = measured
      velocity = [Float](repeating: 0, count: dim)
      lastUpdateNs = timestampNs
      initialized = true
      return
    }
    let dt = Float(max(timestampNs - lastUpdateNs, 1_000_000)) / 1_000_000_000
    var st = state!
    var vel = velocity!
    for i in 0..<dim {
      let predicted = st[i] + vel[i] * dt
      let innovation = measured[i] - predicted
      st[i] = predicted + KalmanTuningIOS.posGain * innovation
      let observedVel = innovation / dt
      vel[i] = vel[i] * (1 - KalmanTuningIOS.velGain) + observedVel * KalmanTuningIOS.velGain
    }
    state = st
    velocity = vel
    lastUpdateNs = timestampNs
  }

  func predict(timestampNs: Int64) -> [Float]? {
    guard initialized, var st = state, let vel = velocity else { return nil }
    let dt = Float(max(timestampNs - lastUpdateNs, 0)) / 1_000_000_000
    let clampedDt = min(dt, 0.1)
    for i in 0..<dim {
      st[i] = (st[i] + vel[i] * clampedDt).clamped(to: 0...1)
    }
    return st
  }
}

private extension Float {
  func clamped(to range: ClosedRange<Float>) -> Float {
    min(max(self, range.lowerBound), range.upperBound)
  }
}
