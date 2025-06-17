//
//  CameraViewController.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import UIKit
import AVFoundation
import Vision

protocol CameraViewControllerDelegate: AnyObject {
    func didCaptureBarcode(_ code: String)
    func didEncounterError(_ error: String)
}

class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let visionQueue = DispatchQueue(label: "com.vinscanner.vision", qos: .userInitiated)
    private var torchDevice: AVCaptureDevice?
    
    var isSessionRunning: Bool {
        return captureSession.isRunning
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    private func setupCamera() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            delegate?.didEncounterError("Camera not available")
            return
        }
        
        torchDevice = videoDevice
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            captureSession.beginConfiguration()
            captureSession.sessionPreset = .hd1920x1080
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: visionQueue)
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            captureSession.commitConfiguration()
            
            setupPreviewLayer()
            
        } catch {
            delegate?.didEncounterError("Failed to setup camera: \(error.localizedDescription)")
        }
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
    }
    
    func startSession() {
        guard !captureSession.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func updateTorchState(_ enabled: Bool) {
        guard let device = torchDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = enabled ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch error: \(error)")
        }
    }
    private func performTextRecognition(on pixelBuffer: CVPixelBuffer) {
        let textRequest = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                print("Text recognition error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            // Look for VIN patterns in recognized text
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                let recognizedText = topCandidate.string.uppercased()
                
                // Look for 17-character alphanumeric strings that could be VINs
                let vinPattern = #"[A-HJ-NPR-Z0-9]{17}"#
                let regex = try? NSRegularExpression(pattern: vinPattern)
                let range = NSRange(location: 0, length: recognizedText.count)
                
                if let match = regex?.firstMatch(in: recognizedText, range: range) {
                    let matchRange = Range(match.range, in: recognizedText)!
                    let potentialVIN = String(recognizedText[matchRange])
                    
                    if VINValidator.isValidVIN(potentialVIN) {
                        DispatchQueue.main.async {
                            self?.delegate?.didCaptureBarcode(potentialVIN)
                        }
                        return
                    }
                }
            }
        }
        
        // Configure text recognition for better accuracy
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = false
        textRequest.revision = VNRecognizeTextRequest.currentRevision
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        do {
            try handler.perform([textRequest])
        } catch {
            print("Text recognition request failed: \(error)")
        }
    }
}

// MARK: - Camera Delegate Extension
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            // Perform barcode detection
//            let barcodeRequest = VNDetectBarcodesRequest { [weak self] request, error in
//                if let error = error {
//                    print("Vision error: \(error)")
//                    return
//                }
//                
//                guard let observations = request.results as? [VNBarcodeObservation] else { return }
//                
//                // Look for VIN-compatible barcodes
//                for observation in observations {
//                    if let payload = observation.payloadStringValue,
//                       (observation.symbology == .code39 || observation.symbology == .code128 || observation.symbology == .code93) {
//                        self?.delegate?.didCaptureBarcode(payload)
//                        return
//                    }
//                }
//            }
//            
//            barcodeRequest.symbologies = [.code39, .code128, .code93]
            
            // Perform both barcode and text recognition
//            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
//            do {
//                try handler.perform([barcodeRequest])
                
                // Also perform text recognition for VIN text
                self.performTextRecognition(on: pixelBuffer)
//            } catch {
//                print("Vision request failed: \(error)")
//            }
    }
}

