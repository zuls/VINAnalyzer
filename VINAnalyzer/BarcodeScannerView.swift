//
//  BarcodeScannerView.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import SwiftUI
import AVFoundation
import Vision

struct BarcodeScannerView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.updateTorchState(viewModel.torchEnabled)
        
        if viewModel.isScanning && !uiViewController.isSessionRunning {
            uiViewController.startSession()
        } else if !viewModel.isScanning && uiViewController.isSessionRunning {
            uiViewController.stopSession()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        let viewModel: ScannerViewModel
        
        init(viewModel: ScannerViewModel) {
            self.viewModel = viewModel
        }
        
        func didCaptureBarcode(_ code: String) {
            viewModel.handleScannedBarcode(code)
        }
        
        func didEncounterError(_ error: String) {
            viewModel.showError(message: error)
        }
    }
}
