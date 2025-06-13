---

# VINScan: Smart VIN Scanner

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=for-the-badge&logo=swift&logoColor=white)
![Vision](https://img.shields.io/badge/Vision-FF2D55?style=for-the-badge&logo=apple&logoColor=white)
![AVFoundation](https://img.shields.io/badge/AVFoundation-007AFF?style=for-the-badge&logo=apple&logoColor=white)

A robust and user-friendly iOS application built with **SwiftUI** that allows users to quickly scan and validate Vehicle Identification Numbers (VINs) using their device's camera. It includes comprehensive VIN validation, camera permission handling, an intuitive scanning overlay, and manual VIN entry capabilities.

---

## Features

* **VIN Barcode Scanning:** Utilizes AVFoundation and Vision framework for efficient and accurate barcode detection (Code 39, Code 93, Code 128).
* **Comprehensive VIN Validation:** Implements the official VIN check digit algorithm to ensure scanned VINs are authentic and correctly formatted.
* **Real-time Scanning Feedback:** Provides clear visual cues and status updates during the scanning process.
* **Torch Control:** Allows users to toggle the flashlight for scanning in low-light conditions.
* **Manual VIN Entry:** Offers an alternative method to input VINs manually with real-time validation.
* **VIN Information Display:** After a successful scan, the app presents the VIN along with parsed information such as World Manufacturer, Vehicle Descriptor, and Serial Number.
* **Copy VIN:** Easily copy the scanned or manually entered VIN to the clipboard.
* **Camera Permission Management:** Gracefully handles camera access requests and provides user-friendly guidance for permission changes.
* **Clean Architecture:** Structured with dedicated view models and utility classes for maintainability and scalability.

---

## Screenshots



| Scan Screen | 
|:---:|
| ![IMG_B7F3280ED968-1](https://github.com/user-attachments/assets/cd57c2c6-f78d-43b4-be2b-d0b2586a748d)
 |  ![IMG_249C191CECCF-1](https://github.com/user-attachments/assets/a3e22aa0-e15f-402b-8b68-204dba783d6f)
| ![IMG_2E24CD66D49D-1](https://github.com/user-attachments/assets/6017b8c0-672c-41ba-9ce9-3a678339acfa)
 |

---

## How It Works

The application is structured into several key components:

* **`VINValidator.swift`**: Contains static methods for validating a VIN, including a lookup table for transliteration values and the check digit algorithm. It ensures that the scanned or manually entered VIN adheres to ISO 3779 standards.
* **`CameraPermissionManager.swift`**: An `ObservableObject` that manages the camera authorization status, providing methods to check and request camera access.
* **`ScannerViewModel.swift`**: The central `ObservableObject` that drives the scanner's state. It manages scanning initiation, termination, barcode handling, error messages, and a scan timeout.
* **`BarcodeScannerView.swift`**: A `UIViewControllerRepresentable` wrapper for `CameraViewController`, bridging UIKit's `AVCaptureSession` and `Vision` framework with SwiftUI.
* **`CameraViewController.swift`**: A UIKit `UIViewController` responsible for setting up and managing the `AVCaptureSession`, processing video frames for barcode detection using `VNDetectBarcodesRequest`, and controlling the device's torch.
* **`ScannerOverlayView.swift`**: A SwiftUI `View` that provides the visual overlay for the camera feed, including a scanning frame, instructional text, status indicators, and controls like the torch toggle and manual entry button.
* **`VINDisplayView.swift`**: Displays the successfully scanned VIN along with a breakdown of its components (WMI, VDS, etc.) and offers actions like copying or rescanning.
* **`ManualEntryView.swift`**: A SwiftUI `View` for users to type in VINs manually, complete with real-time validation feedback.
* **`ContentView.swift`**: The main SwiftUI view that acts as the coordinator, switching between the scanner, VIN display, manual entry, and permission request views based on the application's state and camera permissions.

---

## Installation & Usage

To run this project, you'll need **Xcode 14** or newer.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/zuls/VINAnalyzer.git
    cd VINAnalyzer
    ```
2.  **Open in Xcode:**
    Open the `VINAnalyzer.xcodeproj` file in Xcode.
3.  **Build and Run:**
    Select your target device (an iOS simulator or a physical device) and click the "Run" button.

---

## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements, bug fixes, or new features, please feel free to open an [issue](https://github.com/zuls/VINAnalyzer/issues) or submit a [pull request](https://github.com/zuls/VINAnalyzer/pulls).

````
