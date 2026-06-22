//
//  CameraService.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit
import AVFoundation

/// Camera service errors
enum CameraError: LocalizedError {
    case unauthorized
    case setupFailed
    case captureError(Error)
    case noCameraAvailable

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Camera access not authorized"
        case .setupFailed:
            return "Failed to setup camera"
        case .captureError(let error):
            return "Failed to capture photo: \(error.localizedDescription)"
        case .noCameraAvailable:
            return "No camera available on this device"
        }
    }
}

/// Manages camera capture using AVFoundation
class CameraService: NSObject {
    private let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentCameraPosition: AVCaptureDevice.Position = .back

    private var photoCaptureCompletion: ((Result<UIImage, Error>) -> Void)?

    // MARK: - Setup

    func setupCamera(in view: UIView) throws {
        // Check authorization
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        guard status == .authorized else {
            throw CameraError.unauthorized
        }

        // Configure session
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        // Setup camera device
        try setupCameraDevice(position: .back)

        // Add photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            throw CameraError.setupFailed
        }

        captureSession.commitConfiguration()

        // Setup preview layer
        setupPreviewLayer(in: view)
    }

    private func setupCameraDevice(position: AVCaptureDevice.Position) throws {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            throw CameraError.noCameraAvailable
        }

        let input = try AVCaptureDeviceInput(device: device)

        // Remove existing inputs
        captureSession.inputs.forEach { captureSession.removeInput($0) }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            currentCameraPosition = position
        } else {
            throw CameraError.setupFailed
        }
    }

    private func setupPreviewLayer(in view: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }

    func updatePreviewLayerFrame(_ frame: CGRect) {
        previewLayer?.frame = frame
    }

    // MARK: - Session Control

    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }

    // MARK: - Photo Capture

    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        self.photoCaptureCompletion = completion

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Camera Control

    func switchCamera() throws {
        let newPosition: AVCaptureDevice.Position = currentCameraPosition == .back ? .front : .back

        captureSession.beginConfiguration()
        try setupCameraDevice(position: newPosition)
        captureSession.commitConfiguration()
    }

    func toggleFlash() {
        // Flash will be controlled through AVCapturePhotoSettings
    }

    func setFocus(at point: CGPoint, in view: UIView) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              device.isFocusPointOfInterestSupported else {
            return
        }

        // Convert point to camera coordinates
        let focusPoint = previewLayer?.captureDevicePointConverted(fromLayerPoint: point) ?? point

        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = focusPoint
            device.focusMode = .autoFocus
            device.exposurePointOfInterest = focusPoint
            device.exposureMode = .autoExpose
            device.unlockForConfiguration()
        } catch {
            print("Failed to set focus: \(error)")
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            photoCaptureCompletion?(.failure(CameraError.captureError(error)))
            photoCaptureCompletion = nil
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCaptureCompletion?(.failure(CameraError.captureError(
                NSError(domain: "CameraService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
            )))
            photoCaptureCompletion = nil
            return
        }

        photoCaptureCompletion?(.success(image))
        photoCaptureCompletion = nil
    }
}
