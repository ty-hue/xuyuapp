import Foundation

/// Matches Android [KalmanTuning] / [LandmarkKalmanFilter] for cross-platform AR timing.
enum KalmanTuningIOS {
  static let posGain: Float = 0.88
  static let velGain: Float = 0.56
}
