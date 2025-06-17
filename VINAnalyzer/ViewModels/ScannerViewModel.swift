//
//  ScannerViewModel.swift
//  VINAnalyzer
//
//  Created by Zularbine Kamal on 6/13/25.
//

import SwiftUI
import Combine

class ScannerViewModel: ObservableObject {
    @Published var scannedVIN: String?
    @Published var isScanning = false
    @Published var scanningStatus: ScanningStatus = .ready
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var torchEnabled = false
    
    private var scanTimeoutTimer: Timer?
    private let scanTimeout: TimeInterval = 30.0
    
    enum ScanningStatus {
        case ready
        case scanning
        case success
        case failed
        case timeout
    }
    
    func startScanning() {
        guard !isScanning else { return }
        
        isScanning = true
        scanningStatus = .scanning
        errorMessage = nil
        showError = false
        
        // Set timeout timer
        scanTimeoutTimer = Timer.scheduledTimer(withTimeInterval: scanTimeout, repeats: false) { [weak self] _ in
            self?.handleScanTimeout()
        }
    }
    
    func stopScanning() {
        isScanning = false
        scanTimeoutTimer?.invalidate()
        scanTimeoutTimer = nil
    }
    
    func handleScannedBarcode(_ code: String) {
        guard isScanning else { return }
        
        let cleanedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if VINValidator.isValidVIN(cleanedCode) {
            DispatchQueue.main.async {
                self.scannedVIN = VINValidator.formatVIN(cleanedCode)
                self.scanningStatus = .success
                self.stopScanning()
            }
            return
        }
        if let extractedVIN = VINValidator.extractVINFromText(cleanedCode) {
            DispatchQueue.main.async {
                self.scannedVIN = VINValidator.formatVIN(extractedVIN)
                self.scanningStatus = .success
                self.stopScanning()
            }
            return
        }
        // Continue scanning if VIN is invalid - don't stop for non-VIN barcodes
    }
    
    private func handleScanTimeout() {
        DispatchQueue.main.async {
            self.scanningStatus = .timeout
            self.errorMessage = "Scanning timeout. Try again or enter VIN manually."
            self.showError = true
            self.stopScanning()
        }
    }
    
    func resetScanner() {
        scannedVIN = nil
        scanningStatus = .ready
        errorMessage = nil
        showError = false
        torchEnabled = false
    }
    
    func showError(message: String) {
        errorMessage = message
        showError = true
        scanningStatus = .failed
    }
}
