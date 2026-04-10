package com.example.pixelfree_camera

/**
 * Lightweight predictive filter for 478-landmark face tracking.
 *
 * Uses a simplified 1D Kalman-like model per coordinate:
 *   state = [position, velocity]
 *   predict:  pos += vel * dt
 *   update:   blend predicted with measured, estimate new velocity
 *
 * This provides zero-latency feel: even when detection is 1-2 frames behind,
 * [predict] extrapolates to the current timestamp using velocity.
 */
internal class LandmarkKalmanFilter {
    private var state: FloatArray? = null        // 478*2 positions
    private var velocity: FloatArray? = null      // 478*2 velocities (per-second)
    private var stateZ: FloatArray? = null       // 478 z (MediaPipe depth, not 0..1)
    private var velocityZ: FloatArray? = null
    private var lastUpdateNs: Long = 0L
    private var initialized = false

    // Tuning: how much we trust detection vs prediction (0..1, higher = trust detection more).
    // Slightly snappier velocity so AR mesh / overlays track fast head motion with less “rubber band”.
    // Kept in sync with iOS [VisionFaceSmoother] for cross-platform AR timing.
    private val posGain = KalmanTuning.POS_GAIN
    private val velGain = KalmanTuning.VEL_GAIN

    /**
     * Feed a new detection result. Call from the async MediaPipe callback thread.
     */
    @Synchronized
    fun update(landmarks: FaceLandmarks) {
        val pts = landmarks.points
        val now = landmarks.timestampNs

        if (!initialized || state == null || velocity == null) {
            state = pts.copyOf()
            velocity = FloatArray(FaceLandmarks.ARRAY_SIZE)
            stateZ = landmarks.z.copyOf()
            velocityZ = FloatArray(FaceLandmarks.COUNT)
            lastUpdateNs = now
            initialized = true
            return
        }

        val dt = ((now - lastUpdateNs).coerceAtLeast(1_000_000L)) / 1_000_000_000f // seconds
        val st = state!!
        val vel = velocity!!
        val stZ = stateZ!!
        val velZ = velocityZ!!
        val zIn = landmarks.z

        for (i in 0 until FaceLandmarks.ARRAY_SIZE) {
            val predicted = st[i] + vel[i] * dt
            val measured = pts[i]
            val innovation = measured - predicted

            // Update position: blend predicted toward measured
            st[i] = predicted + posGain * innovation
            // Update velocity: blend old velocity with observed velocity
            val observedVel = innovation / dt
            vel[i] = vel[i] * (1f - velGain) + observedVel * velGain
        }
        for (i in 0 until FaceLandmarks.COUNT) {
            val predicted = stZ[i] + velZ[i] * dt
            val measured = zIn[i]
            val innovation = measured - predicted
            stZ[i] = predicted + posGain * innovation
            val observedVel = innovation / dt
            velZ[i] = velZ[i] * (1f - velGain) + observedVel * velGain
        }
        lastUpdateNs = now
    }

    /**
     * Predict landmark positions for a given timestamp (typically "now").
     * Returns null if no detection has been received yet.
     */
    @Synchronized
    fun predict(timestampNs: Long): FaceLandmarks? {
        if (!initialized) return null
        val st = state ?: return null
        val vel = velocity ?: return null
        val stZ = stateZ ?: return null
        val velZ = velocityZ ?: return null

        val dt = ((timestampNs - lastUpdateNs).coerceAtLeast(0L)) / 1_000_000_000f
        // Cap prediction horizon to 100ms to avoid wild extrapolation
        val clampedDt = dt.coerceAtMost(0.1f)

        val predicted = FloatArray(FaceLandmarks.ARRAY_SIZE)
        for (i in 0 until FaceLandmarks.ARRAY_SIZE) {
            predicted[i] = (st[i] + vel[i] * clampedDt).coerceIn(0f, 1f)
        }
        val predictedZ = FloatArray(FaceLandmarks.COUNT)
        for (i in 0 until FaceLandmarks.COUNT) {
            predictedZ[i] = (stZ[i] + velZ[i] * clampedDt).coerceIn(-0.35f, 0.35f)
        }
        return FaceLandmarks(predicted, timestampNs, predictedZ)
    }

    @Synchronized
    fun reset() {
        state = null
        velocity = null
        stateZ = null
        velocityZ = null
        initialized = false
        lastUpdateNs = 0L
    }

    val hasData: Boolean @Synchronized get() = initialized

    /**
     * True if [update] ran recently — i.e. a real detector measurement exists.
     * Used to gate **beauty** so [predict] alone (dead-reckoning) never whitens background objects.
     */
    @Synchronized
    fun isMeasurementFresh(nowNs: Long, maxAgeNs: Long): Boolean {
        if (!initialized || lastUpdateNs <= 0L) return false
        return (nowNs - lastUpdateNs) <= maxAgeNs
    }
}
