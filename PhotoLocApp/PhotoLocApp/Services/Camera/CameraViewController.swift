//
//  CameraViewController.swift
//  PhotoLocApp
//
//  Created on 2025-11-08.
//

import UIKit
import AVFoundation

/// UIKit camera view controller
class CameraViewController: UIViewController {
    private let cameraService = CameraService()
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - UI Elements

    private lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()

    private lazy var switchCameraButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "camera.rotate", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        return button
    }()

    private lazy var flashButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "bolt.slash", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraService.stopSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraService.updatePreviewLayerFrame(previewView.bounds)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black

        // Add preview
        view.addSubview(previewView)

        // Add controls
        view.addSubview(captureButton)
        view.addSubview(cancelButton)
        view.addSubview(switchCameraButton)
        view.addSubview(flashButton)

        setupConstraints()

        // Add tap gesture for focus
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFocusTap(_:)))
        previewView.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Preview fills the screen
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Capture button at bottom center
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),

            // Cancel button at top left
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Flash button at top right
            flashButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Switch camera button at bottom right
            switchCameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            switchCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
    }

    private func setupCamera() {
        do {
            try cameraService.setupCamera(in: previewView)
        } catch {
            showError(error)
        }
    }

    // MARK: - Actions

    @objc private func capturePhoto() {
        // Animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.captureButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.captureButton.transform = .identity
            }
        }

        cameraService.capturePhoto { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.onPhotoCaptured?(image.fixedOrientation())
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func switchCamera() {
        do {
            try cameraService.switchCamera()
        } catch {
            showError(error)
        }
    }

    @objc private func toggleFlash() {
        // Toggle flash icon
        let currentImage = flashButton.image(for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)

        if currentImage == UIImage(systemName: "bolt.slash", withConfiguration: config) {
            flashButton.setImage(UIImage(systemName: "bolt", withConfiguration: config), for: .normal)
        } else {
            flashButton.setImage(UIImage(systemName: "bolt.slash", withConfiguration: config), for: .normal)
        }
    }

    @objc private func handleFocusTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: previewView)
        cameraService.setFocus(at: point, in: previewView)

        // Show focus indicator
        showFocusIndicator(at: point)
    }

    // MARK: - Helper Methods

    private func showFocusIndicator(at point: CGPoint) {
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusView.center = point
        focusView.layer.borderColor = UIColor.yellow.cgColor
        focusView.layer.borderWidth = 2
        focusView.alpha = 0
        previewView.addSubview(focusView)

        UIView.animate(withDuration: 0.2, animations: {
            focusView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                focusView.alpha = 0
            }) { _ in
                focusView.removeFromSuperview()
            }
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Camera Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
