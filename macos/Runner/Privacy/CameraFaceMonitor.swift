import AVFoundation
import QuartzCore
import Vision

struct VisionFrame {
  var faces: [FaceSample]
  var prints: [VNFeaturePrintObservation]
}

final class CameraFaceMonitor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  var onFrame: ((VisionFrame) -> Void)?
  var onError: ((String) -> Void)?

  private let session = AVCaptureSession()
  private let output = AVCaptureVideoDataOutput()
  private let queue = DispatchQueue(label: "com.example.blurGlass.camera")
  private var lastProcess: TimeInterval = 0
  private let minInterval: TimeInterval = 1.0 / 10.0
  private var running = false

  var isRunning: Bool { running }

  func start() throws {
    if running { return }
    session.beginConfiguration()
    session.sessionPreset = .medium

    session.inputs.forEach { session.removeInput($0) }
    session.outputs.forEach { session.removeOutput($0) }

    guard let device = AVCaptureDevice.default(for: .video) else {
      throw NSError(domain: "BlurGlass", code: 1, userInfo: [NSLocalizedDescriptionKey: "No camera found."])
    }
    let input = try AVCaptureDeviceInput(device: device)
    guard session.canAddInput(input) else {
      throw NSError(domain: "BlurGlass", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot open the camera."])
    }
    session.addInput(input)

    output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    output.alwaysDiscardsLateVideoFrames = true
    output.setSampleBufferDelegate(self, queue: queue)
    guard session.canAddOutput(output) else {
      throw NSError(domain: "BlurGlass", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot read camera frames."])
    }
    session.addOutput(output)
    session.commitConfiguration()
    queue.async { [weak self] in
      self?.session.startRunning()
    }
    running = true
  }

  func stop() {
    guard running else { return }
    queue.async { [weak self] in
      self?.session.stopRunning()
    }
    running = false
  }

  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    let now = CACurrentMediaTime()
    guard now - lastProcess >= minInterval else { return }
    lastProcess = now
    guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

    let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
    let faceRequest = VNDetectFaceLandmarksRequest()
    do {
      try handler.perform([faceRequest])
    } catch {
      onError?(error.localizedDescription)
      return
    }

    let observations = faceRequest.results ?? []
    var prints: [VNFeaturePrintObservation] = []
    var samples: [FaceSample] = []

    for face in observations {
      var printObs: VNFeaturePrintObservation?
      let printRequest = VNGenerateImageFeaturePrintRequest()
      printRequest.regionOfInterest = clampedBox(face.boundingBox)
      if let _ = try? handler.perform([printRequest]) {
        printObs = printRequest.results?.first as? VNFeaturePrintObservation
        if let printObs { prints.append(printObs) }
      }

      let yaw = radiansToDegrees(face.yaw?.doubleValue) ?? yawFromLandmarks(face)
      let pitch = radiansToDegrees(face.pitch?.doubleValue)
      let distance = printObs.flatMap { OwnerIdentityStore.shared.bestDistance(to: $0) }
      samples.append(
        FaceSample(
          yawDegrees: yaw,
          pitchDegrees: pitch,
          area: face.boundingBox.width * face.boundingBox.height,
          ownerDistance: distance
        )
      )
    }

    onFrame?(VisionFrame(faces: samples, prints: prints))
  }

  private func clampedBox(_ box: CGRect) -> CGRect {
    // Add 15% margin around face landmarks so the entire facial contour and structure are captured
    let marginX = box.width * 0.15
    let marginY = box.height * 0.15
    let x = max(0.0, box.origin.x - marginX)
    let y = max(0.0, box.origin.y - marginY)
    let w = min(1.0 - x, box.width + 2 * marginX)
    let h = min(1.0 - y, box.height + 2 * marginY)
    return CGRect(x: x, y: y, width: max(0.02, w), height: max(0.02, h))
  }

  private func radiansToDegrees(_ value: Double?) -> Double? {
    guard let value else { return nil }
    return value * 180.0 / .pi
  }

  private func yawFromLandmarks(_ face: VNFaceObservation) -> Double? {
    guard let left = face.landmarks?.leftEye?.normalizedPoints, !left.isEmpty,
          let right = face.landmarks?.rightEye?.normalizedPoints, !right.isEmpty else {
      return nil
    }
    let leftX = left.reduce(0) { $0 + $1.x } / CGFloat(left.count)
    let rightX = right.reduce(0) { $0 + $1.x } / CGFloat(right.count)
    let mid = (leftX + rightX) / 2
    // Face-local x: 0.5 is center. Shift from center maps to a rough yaw.
    return Double((mid - 0.5) * 90)
  }
}
