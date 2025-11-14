# Polaroid Photo Location App - Detailed Implementation Plan

## Project Overview

**App Name**: PhotoLoc (working title)
**Platform**: iOS (iPhone 11 and above)
**Minimum iOS Version**: iOS 14.0
**Language**: Swift 5.5+
**UI Framework**: SwiftUI + UIKit (for camera)
**Design System**: Apple Human Interface Guidelines

### Core Features
1. Capture photos with camera
2. Select existing photos from library
3. Extract GPS location from photo metadata (EXIF)
4. Generate Polaroid-style output with white border at bottom
5. Display QR code with Google Maps link
6. Display photo description/metadata text
7. 100% offline operation
8. Save to Photos library

---

## Technical Requirements

### iOS SDK & Frameworks

| Framework | Purpose | Offline |
|-----------|---------|---------|
| **SwiftUI** | Main UI framework | ✅ |
| **UIKit** | Camera integration, legacy components | ✅ |
| **AVFoundation** | Camera capture, video preview | ✅ |
| **CoreLocation** | GPS coordinates, location services | ✅ |
| **Photos/PhotosUI** | Photo library access, PHPicker | ✅ |
| **CoreImage** | QR code generation, image filters | ✅ |
| **CoreGraphics** | Image composition, drawing | ✅ |
| **ImageIO** | EXIF metadata extraction | ✅ |

### Device Requirements
- **Minimum**: iPhone 11 (iOS 14.0+)
- **Camera**: Requires rear/front camera
- **Storage**: Local photo library access
- **Sensors**: GPS capability

### Permissions Required
```xml
NSCameraUsageDescription
NSPhotoLibraryUsageDescription
NSPhotoLibraryAddUsageDescription
NSLocationWhenInUseUsageDescription
```

---

## Architecture

### MVVM Pattern

```
┌─────────────────────────────────────────────────┐
│                   Views (SwiftUI)               │
│  - HomeView                                     │
│  - CameraView                                   │
│  - PhotoPickerView                              │
│  - PolaroidPreviewView                          │
│  - SettingsView                                 │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│              ViewModels                         │
│  - CameraViewModel                              │
│  - PhotoProcessorViewModel                      │
│  - SettingsViewModel                            │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│              Services                           │
│  - CameraService                                │
│  - LocationService                              │
│  - PhotoLibraryService                          │
│  - EXIFReader                                   │
│  - QRCodeGenerator                              │
│  - PolaroidCompositor                           │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│              Models                             │
│  - PhotoMetadata                                │
│  - LocationData                                 │
│  - PolaroidStyle                                │
└─────────────────────────────────────────────────┘
```

### Project Structure

```
PhotoLocApp/
├── PhotoLocApp.swift (App entry point)
├── Info.plist
│
├── Views/
│   ├── HomeView.swift
│   ├── CameraView.swift
│   ├── PhotoPickerView.swift
│   ├── PolaroidPreviewView.swift
│   ├── SettingsView.swift
│   └── Components/
│       ├── PermissionPromptView.swift
│       └── LoadingView.swift
│
├── ViewModels/
│   ├── CameraViewModel.swift
│   ├── PhotoProcessorViewModel.swift
│   └── SettingsViewModel.swift
│
├── Services/
│   ├── Camera/
│   │   ├── CameraService.swift
│   │   └── CameraViewController.swift (UIKit)
│   ├── Location/
│   │   └── LocationService.swift
│   ├── Photo/
│   │   ├── PhotoLibraryService.swift
│   │   └── EXIFReader.swift
│   ├── Processing/
│   │   ├── QRCodeGenerator.swift
│   │   └── PolaroidCompositor.swift
│   └── Permissions/
│       └── PermissionManager.swift
│
├── Models/
│   ├── PhotoMetadata.swift
│   ├── LocationData.swift
│   ├── PolaroidStyle.swift
│   └── AppSettings.swift
│
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions/
│   │   ├── UIImage+Extensions.swift
│   │   ├── CLLocation+Extensions.swift
│   │   └── Date+Extensions.swift
│   └── Helpers/
│       └── CoordinateFormatter.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon
│   │   └── Colors
│   └── Localizable.strings
│
└── Tests/
    ├── UnitTests/
    └── UITests/
```

---

## Detailed Task Breakdown

## PHASE 1: Project Setup & Foundation (Week 1)

### Task 1.1: Xcode Project Initialization
**Duration**: 2 hours
**Priority**: Critical

**Steps**:
1. Create new Xcode project
   - Template: iOS App
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: iOS 14.0

2. Configure project settings
   - Bundle Identifier: `com.yourcompany.photoloc`
   - Team & Signing
   - Supported devices: iPhone only
   - Supported orientations: Portrait, Landscape

3. Set up folder structure (as outlined above)

**Deliverable**: Empty project with proper structure

---

### Task 1.2: Configure Info.plist & Permissions
**Duration**: 1 hour
**Priority**: Critical

**Steps**:
1. Add privacy descriptions:
```xml
<key>NSCameraUsageDescription</key>
<string>PhotoLoc needs camera access to capture photos with location data</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>PhotoLoc needs access to your photo library to select and process existing photos</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>PhotoLoc needs permission to save processed Polaroid-style photos to your library</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>PhotoLoc needs your location to tag photos with GPS coordinates</string>
```

2. Set supported interface orientations
3. Configure app capabilities if needed

**Deliverable**: Configured Info.plist with all permissions

---

### Task 1.3: Create Models
**Duration**: 3 hours
**Priority**: High

**Files to Create**:

**PhotoMetadata.swift**
```swift
struct PhotoMetadata {
    let image: UIImage
    let location: LocationData?
    let timestamp: Date
    let description: String?
    let cameraMake: String?
    let cameraModel: String?
}
```

**LocationData.swift**
```swift
struct LocationData {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let timestamp: Date

    var googleMapsURL: String {
        "https://maps.google.com/?q=\(latitude),\(longitude)"
    }

    var formattedCoordinates: String {
        // Format: 37.7749° N, 122.4194° W
    }
}
```

**PolaroidStyle.swift**
```swift
struct PolaroidStyle {
    let borderColor: UIColor
    let borderWidth: CGFloat
    let bottomSpaceHeight: CGFloat // Height of white space
    let qrCodeSize: CGSize
    let textFont: UIFont
    let textColor: UIColor

    static let classic: PolaroidStyle // White border, classic look
}
```

**AppSettings.swift**
```swift
class AppSettings: ObservableObject {
    @Published var polaroidStyle: PolaroidStyle
    @Published var includeTimestamp: Bool
    @Published var includeCoordinates: Bool
    @Published var saveToLibraryAutomatically: Bool
}
```

**Deliverable**: All model files with proper structure

---

### Task 1.4: Create Constants & Extensions
**Duration**: 2 hours
**Priority**: Medium

**Constants.swift**
```swift
enum AppConstants {
    // UI
    static let polaroidBottomHeight: CGFloat = 200
    static let polaroidBorderWidth: CGFloat = 20
    static let qrCodeSize: CGFloat = 120

    // Image Processing
    static let maxImageDimension: CGFloat = 3000
    static let jpegCompressionQuality: CGFloat = 0.9

    // Colors (HIG compliant)
    static let polaroidBackground = UIColor.systemBackground
    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel
}
```

**Extensions to create**:
- `UIImage+Extensions.swift`: Resize, compress, orientation fixes
- `CLLocation+Extensions.swift`: Coordinate formatting
- `Date+Extensions.swift`: Timestamp formatting
- `View+Extensions.swift`: SwiftUI helpers

**Deliverable**: Utility files with reusable code

---

## PHASE 2: Permission Management (Week 1-2)

### Task 2.1: Create PermissionManager Service
**Duration**: 4 hours
**Priority**: Critical

**PermissionManager.swift**

Features:
- Check camera permission status
- Request camera permission
- Check photo library permission
- Request photo library permission
- Check location permission
- Request location permission
- Handle all permission states (authorized, denied, restricted, notDetermined)

**Implementation**:
```swift
class PermissionManager: ObservableObject {
    @Published var cameraStatus: PermissionStatus = .notDetermined
    @Published var photoLibraryStatus: PermissionStatus = .notDetermined
    @Published var locationStatus: PermissionStatus = .notDetermined

    func requestCameraPermission() async -> Bool
    func requestPhotoLibraryPermission() async -> Bool
    func requestLocationPermission() async -> Bool
    func openSettings()
}

enum PermissionStatus {
    case notDetermined
    case authorized
    case denied
    case restricted
}
```

**Deliverable**: Complete permission management system

---

### Task 2.2: Create Permission UI Views
**Duration**: 3 hours
**Priority**: High

**PermissionPromptView.swift**

Features:
- Beautiful onboarding-style permission explanation
- Follow HIG for requesting permissions
- Explain why each permission is needed
- Show permission status
- Button to open Settings if denied

**Design Guidelines**:
- Use SF Symbols for icons
- Clear, concise explanations
- Primary action buttons
- Non-intrusive design

**Deliverable**: SwiftUI permission prompt views

---

## PHASE 3: Location Services (Week 2)

### Task 3.1: Create LocationService
**Duration**: 5 hours
**Priority**: Critical

**LocationService.swift**

Features:
- Request location permission
- Get current location
- Handle location errors
- Location accuracy settings
- Timeout handling for slow GPS

**Implementation**:
```swift
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    private let locationManager = CLLocationManager()

    func requestLocation() async throws -> CLLocation
    func startUpdatingLocation()
    func stopUpdatingLocation()

    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager,
                        didUpdateLocations locations: [CLLocation])
    func locationManager(_ manager: CLLocationManager,
                        didFailWithError error: Error)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
}
```

**Error Handling**:
- Location services disabled
- Location unavailable
- Timeout scenarios
- Permission denied

**Deliverable**: Complete location service with error handling

---

### Task 3.2: Create EXIF Reader
**Duration**: 4 hours
**Priority**: Critical

**EXIFReader.swift**

Features:
- Extract GPS coordinates from photo metadata
- Extract timestamp
- Extract camera make/model
- Handle photos without location data
- Support various image formats (JPEG, HEIC)

**Implementation**:
```swift
class EXIFReader {
    static func extractMetadata(from image: UIImage) -> PhotoMetadata?
    static func extractLocation(from image: UIImage) -> LocationData?
    static func extractTimestamp(from image: UIImage) -> Date?
    static func extractCameraInfo(from image: UIImage) -> (make: String?, model: String?)
}
```

**Technical Details**:
- Use `ImageIO` framework
- Read `kCGImagePropertyGPSDictionary`
- Parse latitude, longitude, altitude
- Handle coordinate reference (N/S, E/W)

**Deliverable**: EXIF metadata extraction service

---

## PHASE 4: Photo Library Integration (Week 2-3)

### Task 4.1: Create PhotoLibraryService
**Duration**: 4 hours
**Priority**: High

**PhotoLibraryService.swift**

Features:
- Present PHPickerViewController (iOS 14+)
- Handle photo selection
- Save processed images to library
- Handle permission states

**Implementation**:
```swift
class PhotoLibraryService: NSObject {
    func presentPhotoPicker(on viewController: UIViewController,
                          delegate: PHPickerViewControllerDelegate)

    func saveImage(_ image: UIImage,
                   completion: @escaping (Result<Bool, Error>) -> Void)

    func checkPermission() -> PHAuthorizationStatus
    func requestPermission() async -> PHAuthorizationStatus
}
```

**Deliverable**: Photo library service with picker integration

---

### Task 4.2: Create PhotoPickerView (SwiftUI)
**Duration**: 3 hours
**Priority**: High

**PhotoPickerView.swift**

Features:
- SwiftUI wrapper for PHPickerViewController
- Single photo selection
- Handle selected photo
- Modern iOS design

**Implementation**:
```swift
struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController
    func updateUIViewController(_ uiViewController: PHPickerViewController,
                               context: Context)
    func makeCoordinator() -> Coordinator
}
```

**Deliverable**: SwiftUI photo picker component

---

## PHASE 5: Camera Integration (Week 3)

### Task 5.1: Create CameraService (UIKit)
**Duration**: 8 hours
**Priority**: Critical

**CameraService.swift & CameraViewController.swift**

Features:
- AVFoundation camera setup
- Photo capture
- Camera preview layer
- Focus, exposure controls
- Flash control
- Front/rear camera switching
- Capture button UI

**Implementation**:
```swift
class CameraService: NSObject {
    private let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func setupCamera() throws
    func startSession()
    func stopSession()
    func capturePhoto(completion: @escaping (UIImage?) -> Void)
    func switchCamera()
    func toggleFlash()
}

class CameraViewController: UIViewController {
    private let cameraService = CameraService()
    var onPhotoCaptured: ((UIImage) -> Void)?

    // UI Elements
    private let captureButton: UIButton
    private let cancelButton: UIButton
    private let flashButton: UIButton
    private let switchCameraButton: UIButton
}
```

**UI Design (HIG compliant)**:
- Large capture button at bottom center
- Cancel button top-left
- Flash toggle top-right
- Camera switch bottom-right
- Clean, minimal interface
- System blur effects for controls

**Deliverable**: Fully functional camera with UIKit

---

### Task 5.2: Create CameraView (SwiftUI Wrapper)
**Duration**: 3 hours
**Priority**: High

**CameraView.swift**

Features:
- SwiftUI wrapper for UIKit camera
- Handle captured photos
- Pass photo to parent view
- Dismiss camera

**Implementation**:
```swift
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var currentLocation: CLLocation?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> CameraViewController
    func updateUIViewController(_ uiViewController: CameraViewController,
                               context: Context)
    func makeCoordinator() -> Coordinator
}
```

**Deliverable**: SwiftUI camera wrapper

---

### Task 5.3: Create CameraViewModel
**Duration**: 3 hours
**Priority**: High

**CameraViewModel.swift**

Features:
- Coordinate camera and location services
- Handle photo capture flow
- Store captured image and location
- Error handling
- Loading states

**Implementation**:
```swift
@MainActor
class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var currentLocation: CLLocation?
    @Published var isLoading = false
    @Published var error: AppError?

    private let locationService: LocationService
    private let cameraService: CameraService

    func capturePhoto()
    func handleCapturedPhoto(_ image: UIImage)
    func resetCamera()
}
```

**Deliverable**: Camera view model with business logic

---

## PHASE 6: Image Processing (Week 3-4)

### Task 6.1: Create QRCodeGenerator
**Duration**: 3 hours
**Priority**: Critical

**QRCodeGenerator.swift**

Features:
- Generate QR code from Google Maps URL
- High resolution output
- Error correction level: Medium
- Return UIImage

**Implementation**:
```swift
class QRCodeGenerator {
    static func generateQRCode(from url: String,
                              size: CGSize) -> UIImage? {
        // Use CIQRCodeGenerator filter
        // Input: URL string
        // Output: High-resolution UIImage

        // Steps:
        // 1. Create CIFilter with name "CIQRCodeGenerator"
        // 2. Set input message (URL as Data)
        // 3. Set error correction level
        // 4. Get output CIImage
        // 5. Scale to desired size
        // 6. Convert to UIImage
    }
}
```

**Technical Details**:
- Use `CIFilter(name: "CIQRCodeGenerator")`
- Error correction: `.M` (medium, ~15% recovery)
- Scale transform for sizing
- Maintain crisp edges

**Deliverable**: QR code generation service

---

### Task 6.2: Create PolaroidCompositor
**Duration**: 8 hours
**Priority**: Critical

**PolaroidCompositor.swift**

This is the most complex image processing component.

**Features**:
- Composite photo with Polaroid-style border
- Add white space at bottom (200pt)
- Add QR code to bottom section
- Add text (coordinates, date, description)
- Professional layout
- Handle various aspect ratios

**Implementation**:
```swift
class PolaroidCompositor {
    func createPolaroidImage(
        from photo: UIImage,
        metadata: PhotoMetadata,
        style: PolaroidStyle
    ) -> UIImage? {
        // Composition steps:
        // 1. Calculate dimensions
        // 2. Create graphics context
        // 3. Draw white border background
        // 4. Draw original photo (top section)
        // 5. Draw bottom white space
        // 6. Draw QR code (bottom-left)
        // 7. Draw text content (bottom-right)
        // 8. Return composite image
    }

    private func calculatePolaroidDimensions(
        for photo: UIImage,
        style: PolaroidStyle
    ) -> PolaroidDimensions

    private func drawBottomSection(
        in context: CGContext,
        qrCode: UIImage,
        metadata: PhotoMetadata,
        rect: CGRect,
        style: PolaroidStyle
    )
}

struct PolaroidDimensions {
    let totalSize: CGSize
    let photoFrame: CGRect
    let bottomFrame: CGRect
    let qrCodeFrame: CGRect
    let textFrame: CGRect
}
```

**Layout Design**:
```
┌────────────────────────────────────┐
│                                    │
│                                    │
│          Original Photo            │
│                                    │
│                                    │
├────────────────────────────────────┤ ← Border (20pt)
│                                    │
│  ┌────┐  Photo Details            │
│  │ QR │  37.7749° N, 122.4194° W  │
│  │Code│  Dec 15, 2023 • 2:30 PM   │
│  └────┘  "Golden Gate Bridge"     │
│                                    │
└────────────────────────────────────┘
```

**Technical Details**:
- Use `UIGraphicsBeginImageContextWithOptions` for high quality
- Border width: 20pt on all sides
- Bottom space: 200pt height
- QR code: 120x120pt, 20pt from left/bottom
- Text: UIFont.systemFont (San Francisco)
- Text color: .label (adaptive for dark mode)
- Antialiasing enabled

**Deliverable**: Complete Polaroid compositor

---

### Task 6.3: Create PhotoProcessorViewModel
**Duration**: 4 hours
**Priority**: Critical

**PhotoProcessorViewModel.swift**

Features:
- Coordinate photo processing pipeline
- Generate QR code
- Create Polaroid composite
- Handle async operations
- Error handling
- Progress indication

**Implementation**:
```swift
@MainActor
class PhotoProcessorViewModel: ObservableObject {
    @Published var originalImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var metadata: PhotoMetadata?
    @Published var isProcessing = false
    @Published var error: AppError?

    private let qrGenerator: QRCodeGenerator
    private let compositor: PolaroidCompositor
    private let exifReader: EXIFReader

    func processPhoto(
        image: UIImage,
        location: CLLocation?,
        description: String?
    ) async {
        // 1. Extract/use location
        // 2. Create metadata
        // 3. Generate QR code
        // 4. Composite Polaroid image
        // 5. Update UI
    }

    func processExistingPhoto(_ image: UIImage) async {
        // 1. Extract EXIF data
        // 2. Get location from EXIF
        // 3. Process like captured photo
    }

    func saveToLibrary() async throws
    func reset()
}
```

**Deliverable**: Photo processing view model

---

## PHASE 7: User Interface (Week 4-5)

### Task 7.1: Create HomeView
**Duration**: 6 hours
**Priority**: Critical

**HomeView.swift**

Features:
- Main landing screen
- Two primary actions: Take Photo / Select Photo
- Recent photos grid (optional)
- Settings button
- Beautiful, minimal design

**Layout**:
```
┌─────────────────────────────────────┐
│  ⚙️                     PhotoLoc   │
├─────────────────────────────────────┤
│                                     │
│         📷                          │
│                                     │
│    Create Polaroid Memories        │
│     with Location Tags             │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  📸 Take Photo              │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  🖼️ Select from Library     │  │
│  └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**HIG Compliance**:
- SF Symbols for icons
- System fonts (San Francisco)
- Adaptive colors (light/dark mode)
- Proper spacing (8pt, 16pt, 24pt grid)
- Large touch targets (44pt minimum)
- Native SwiftUI components

**Implementation**:
```swift
struct HomeView: View {
    @StateObject private var permissionManager = PermissionManager()
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Hero section
                // Primary buttons
                // Recent photos (optional)
            }
            .navigationTitle("PhotoLoc")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}
```

**Deliverable**: Main home screen

---

### Task 7.2: Create PolaroidPreviewView
**Duration**: 6 hours
**Priority**: High

**PolaroidPreviewView.swift**

Features:
- Display processed Polaroid image
- Pinch to zoom
- Save button
- Share button
- Edit description button
- Retake/Select different photo
- Loading state during processing

**Layout**:
```
┌─────────────────────────────────────┐
│  ← Back                    Share ↗  │
├─────────────────────────────────────┤
│                                     │
│      ┌───────────────────┐         │
│      │                   │         │
│      │   Polaroid Image  │         │
│      │                   │         │
│      │─────────────────── │         │
│      │ QR | Description  │         │
│      └───────────────────┘         │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  💾 Save to Library         │  │
│  └─────────────────────────────┘  │
│                                     │
│  ✏️ Edit Description               │
│                                     │
└─────────────────────────────────────┘
```

**Features**:
```swift
struct PolaroidPreviewView: View {
    @ObservedObject var viewModel: PhotoProcessorViewModel
    @State private var isEditingDescription = false
    @State private var showShareSheet = false
    @State private var showSaveConfirmation = false

    var body: some View {
        // Preview with zoom capability
        // Action buttons
        // Share sheet
        // Description editor
    }

    private func saveToLibrary() async
    private func shareImage()
}
```

**Deliverable**: Preview and save screen

---

### Task 7.3: Create SettingsView
**Duration**: 4 hours
**Priority**: Medium

**SettingsView.swift**

Features:
- Polaroid style customization
- Default description template
- Auto-save toggle
- Include/exclude metadata options
- About section
- Permission status

**Layout**:
```swift
struct SettingsView: View {
    @StateObject private var settings = AppSettings()
    @StateObject private var permissions = PermissionManager()

    var body: some View {
        Form {
            Section("Photo Settings") {
                Toggle("Include Timestamp", isOn: $settings.includeTimestamp)
                Toggle("Include Coordinates", isOn: $settings.includeCoordinates)
                Toggle("Auto-save to Library", isOn: $settings.saveToLibraryAutomatically)
            }

            Section("Permissions") {
                PermissionRow(title: "Camera", status: permissions.cameraStatus)
                PermissionRow(title: "Photos", status: permissions.photoLibraryStatus)
                PermissionRow(title: "Location", status: permissions.locationStatus)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
```

**Deliverable**: Settings screen

---

### Task 7.4: Create Loading & Error Views
**Duration**: 3 hours
**Priority**: Medium

**LoadingView.swift**
- System ProgressView
- Processing message
- Cancellable if needed

**ErrorView.swift**
- Display error messages
- Retry button
- Dismiss button
- User-friendly error descriptions

**Implementation**:
```swift
struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct ErrorView: View {
    let error: AppError
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text(error.title)
                .font(.headline)

            Text(error.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Retry", action: onRetry)
                    .buttonStyle(.borderedProminent)
                Button("Dismiss", action: onDismiss)
                    .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
```

**Deliverable**: Reusable loading and error components

---

## PHASE 8: Error Handling & Edge Cases (Week 5)

### Task 8.1: Define Error Types
**Duration**: 2 hours
**Priority**: High

**AppError.swift**

```swift
enum AppError: LocalizedError {
    case cameraUnavailable
    case locationUnavailable
    case locationPermissionDenied
    case photoLibraryPermissionDenied
    case imageProcessingFailed
    case noLocationInPhoto
    case qrCodeGenerationFailed
    case saveFailed(Error)

    var title: String {
        switch self {
        case .cameraUnavailable: return "Camera Unavailable"
        case .locationUnavailable: return "Location Unavailable"
        // ... etc
        }
    }

    var message: String {
        switch self {
        case .cameraUnavailable:
            return "Cannot access camera. Please check Settings."
        // ... etc
        }
    }

    var errorDescription: String? { message }
}
```

**Deliverable**: Comprehensive error handling

---

### Task 8.2: Handle Edge Cases
**Duration**: 6 hours
**Priority**: High

**Edge Cases to Handle**:

1. **Photo without location data**
   - Show alert: "This photo has no location data"
   - Option to manually select location
   - Option to use current location

2. **Location services disabled**
   - Detect system-wide location off
   - Show instructions to enable in Settings
   - Graceful degradation (skip location)

3. **Memory constraints**
   - Large photo handling
   - Resize before processing
   - Release memory properly

4. **Orientation issues**
   - Fix EXIF orientation
   - Handle rotation properly
   - Maintain aspect ratio

5. **Dark mode**
   - Ensure text is readable
   - Adaptive colors
   - Test all screens

6. **Different screen sizes**
   - iPhone 11: 6.1"
   - iPhone 13 Pro Max: 6.7"
   - iPhone SE: 4.7"
   - Responsive layouts

**Implementation Strategy**:
```swift
// Example: Handle missing location
if let location = metadata.location {
    // Normal flow
} else {
    // Show alert with options
    Alert(
        title: Text("No Location Data"),
        message: Text("Use current location?"),
        primaryButton: .default(Text("Use Current")) {
            // Get current location
        },
        secondaryButton: .cancel()
    )
}
```

**Deliverable**: Robust error handling for all edge cases

---

## PHASE 9: Testing (Week 5-6)

### Task 9.1: Unit Tests
**Duration**: 8 hours
**Priority**: High

**Test Files**:

**QRCodeGeneratorTests.swift**
```swift
class QRCodeGeneratorTests: XCTestCase {
    func testQRCodeGeneration()
    func testQRCodeSize()
    func testInvalidURL()
}
```

**EXIFReaderTests.swift**
```swift
class EXIFReaderTests: XCTestCase {
    func testExtractLocationFromJPEG()
    func testExtractLocationFromHEIC()
    func testPhotoWithoutLocation()
    func testExtractTimestamp()
}
```

**PolaroidCompositorTests.swift**
```swift
class PolaroidCompositorTests: XCTestCase {
    func testCompositeCreation()
    func testDifferentAspectRatios()
    func testTextLayout()
    func testQRCodePlacement()
}
```

**LocationDataTests.swift**
```swift
class LocationDataTests: XCTestCase {
    func testGoogleMapsURLGeneration()
    func testCoordinateFormatting()
}
```

**Deliverable**: Unit test suite with >80% coverage

---

### Task 9.2: UI Tests
**Duration**: 6 hours
**Priority**: Medium

**Test Scenarios**:

1. **Photo capture flow**
   - Launch camera
   - Grant permissions
   - Capture photo
   - Preview appears
   - Save to library

2. **Photo selection flow**
   - Open picker
   - Select photo
   - Process photo
   - Preview appears

3. **Permission flows**
   - First launch
   - Permission prompts
   - Denied states
   - Settings navigation

4. **Error scenarios**
   - Handle denied permissions
   - Handle missing location
   - Handle processing errors

**Implementation**:
```swift
class PhotoLocUITests: XCTestCase {
    func testCapturePhotoFlow()
    func testSelectPhotoFlow()
    func testPermissionDenied()
    func testSaveToLibrary()
}
```

**Deliverable**: UI test suite for critical flows

---

### Task 9.3: Manual Testing Checklist
**Duration**: 4 hours
**Priority**: High

**Device Testing**:
- [ ] iPhone 11 (iOS 14)
- [ ] iPhone 12 (iOS 15)
- [ ] iPhone 13 Pro Max (iOS 16)
- [ ] iPhone 14 (iOS 17)

**Scenario Testing**:
- [ ] Take photo with location
- [ ] Take photo without location (airplane mode)
- [ ] Select recent photo with location
- [ ] Select old photo without location
- [ ] Dark mode compatibility
- [ ] Landscape orientation
- [ ] Low memory conditions
- [ ] Background/foreground transitions
- [ ] Permission denial recovery
- [ ] Various image formats (JPEG, HEIC, PNG)
- [ ] Different aspect ratios
- [ ] Large photos (>10MB)
- [ ] QR code scannability
- [ ] Save to library
- [ ] Share sheet

**Deliverable**: Tested app on multiple devices

---

## PHASE 10: Polish & Optimization (Week 6)

### Task 10.1: Performance Optimization
**Duration**: 4 hours
**Priority**: Medium

**Optimizations**:

1. **Image Processing**
   - Perform on background thread
   - Use async/await properly
   - Show progress indicators

2. **Memory Management**
   - Release large images after processing
   - Use autoreleasepool for batch operations
   - Monitor memory usage

3. **Launch Time**
   - Lazy load services
   - Defer permission checks
   - Fast startup

4. **Responsiveness**
   - All operations async
   - No UI blocking
   - Smooth animations

**Implementation**:
```swift
// Example: Background processing
Task.detached(priority: .userInitiated) {
    let processed = await compositor.createPolaroidImage(...)
    await MainActor.run {
        viewModel.processedImage = processed
    }
}
```

**Deliverable**: Optimized app performance

---

### Task 10.2: Accessibility
**Duration**: 3 hours
**Priority**: Medium

**Accessibility Features**:

1. **VoiceOver**
   - All buttons labeled
   - Images with descriptions
   - Proper navigation order

2. **Dynamic Type**
   - Support text sizing
   - Scalable layouts

3. **Color Contrast**
   - WCAG AA compliance
   - High contrast mode support

4. **Reduce Motion**
   - Respect accessibility settings
   - Alternative animations

**Implementation**:
```swift
Button(action: capturePhoto) {
    Image(systemName: "camera.fill")
}
.accessibilityLabel("Capture photo")
.accessibilityHint("Takes a photo with location data")
```

**Deliverable**: Fully accessible app

---

### Task 10.3: App Icon & Assets
**Duration**: 3 hours
**Priority**: High

**Assets Needed**:

1. **App Icon**
   - 1024x1024 master
   - All required sizes (Xcode generates)
   - Polaroid-themed design
   - Camera + location pin concept

2. **Launch Screen**
   - Simple, fast-loading
   - App icon + name
   - System background

3. **Color Assets**
   - Adaptive colors for dark mode
   - Consistent brand colors

**Tools**:
- Use SF Symbols where possible
- Sketch/Figma for icon design
- Export @1x, @2x, @3x

**Deliverable**: Professional app assets

---

## PHASE 11: Final Testing & Release Prep (Week 6-7)

### Task 11.1: Beta Testing
**Duration**: Ongoing
**Priority**: High

**TestFlight Setup**:
1. Configure App Store Connect
2. Upload build via Xcode
3. Add internal testers
4. Add external testers (optional)
5. Collect feedback
6. Fix critical bugs

**Deliverable**: Beta-tested app

---

### Task 11.2: App Store Preparation
**Duration**: 4 hours
**Priority**: High

**Required Materials**:

1. **App Store Listing**
   - App name: "PhotoLoc - Polaroid Location Tags"
   - Subtitle: "Offline Photo Location Tagging"
   - Keywords: polaroid, photo, location, GPS, offline, QR code
   - Description (see below)
   - Privacy policy (simple, no data collection)

2. **Screenshots** (Required sizes)
   - 6.7" (iPhone 14 Pro Max)
   - 6.5" (iPhone 11 Pro Max)
   - 5.5" (iPhone 8 Plus)
   - All screens: Home, Camera, Preview, Settings

3. **App Preview Video** (Optional)
   - 15-30 seconds
   - Show core functionality

**App Description Template**:
```
Transform your photos into beautiful Polaroid-style memories with location tags!

FEATURES:
📸 Capture photos with your location
🖼️ Process existing photos from your library
🗺️ Add QR codes with Google Maps links
✨ Beautiful Polaroid-style borders
🔒 100% offline - no internet required
🎨 Clean, minimal design

HOW IT WORKS:
1. Take a photo or select from library
2. App adds location as QR code
3. Creates Polaroid-style image
4. Save and share your memories!

PRIVACY:
• All processing happens on your device
• No data sent to servers
• No account required
• Your photos stay yours

Perfect for travelers, photographers, and memory keepers!
```

**Deliverable**: Complete App Store listing

---

### Task 11.3: Compliance & Legal
**Duration**: 2 hours
**Priority**: High

**Requirements**:

1. **Privacy Policy**
   ```
   PhotoLoc Privacy Policy

   Data Collection: None
   PhotoLoc does not collect, store, or transmit any user data.
   All processing happens locally on your device.

   Permissions:
   - Camera: To capture photos
   - Photos: To access and save images
   - Location: To tag photos with coordinates

   Data Storage: All data remains on your device
   No analytics, tracking, or third-party services

   Contact: [your email]
   Last updated: [date]
   ```

2. **Terms of Service** (Simple)

3. **Export Compliance**
   - No encryption beyond iOS standard
   - Should be exempt

**Deliverable**: Legal documents

---

## PHASE 12: Release & Maintenance

### Task 12.1: App Store Submission
**Duration**: 1 hour
**Priority**: Critical

**Steps**:
1. Final build in Release configuration
2. Archive in Xcode
3. Upload to App Store Connect
4. Fill all metadata
5. Submit for review
6. Respond to reviewer questions

**Deliverable**: App submitted to App Store

---

### Task 12.2: Post-Launch Monitoring
**Duration**: Ongoing
**Priority**: High

**Monitor**:
- Crash reports (Xcode Organizer)
- User reviews
- Support emails
- Performance metrics

**Quick Fixes**:
- Critical bugs: 24-48 hours
- Minor bugs: Next update
- Feature requests: Backlog

**Deliverable**: Stable released app

---

## Development Timeline Summary

| Phase | Duration | Tasks | Priority |
|-------|----------|-------|----------|
| Phase 1: Setup | 2 days | Project init, models, constants | Critical |
| Phase 2: Permissions | 2 days | Permission management, UI | Critical |
| Phase 3: Location | 2 days | Location service, EXIF reader | Critical |
| Phase 4: Photo Library | 2 days | Library service, picker | High |
| Phase 5: Camera | 3 days | Camera integration, UI | Critical |
| Phase 6: Processing | 3 days | QR generation, compositor | Critical |
| Phase 7: UI | 4 days | All main views | Critical |
| Phase 8: Error Handling | 2 days | Edge cases, errors | High |
| Phase 9: Testing | 3 days | Unit, UI, manual tests | High |
| Phase 10: Polish | 2 days | Optimization, accessibility | Medium |
| Phase 11: Release Prep | 3 days | Beta, App Store materials | High |
| Phase 12: Release | 1 day | Submission | Critical |

**Total Estimated Time**: 6-7 weeks

---

## Technical Specifications Summary

### Minimum Requirements
- **iOS**: 14.0+
- **Devices**: iPhone 11 and newer
- **Xcode**: 13.0+
- **Swift**: 5.5+

### Key Technologies
- SwiftUI + UIKit
- AVFoundation
- CoreLocation
- Photos/PhotosUI
- CoreImage (QR codes)
- CoreGraphics (composition)
- ImageIO (EXIF)

### Performance Targets
- Launch time: < 2 seconds
- Photo processing: < 3 seconds
- Camera preview: 30+ FPS
- Memory: < 150MB typical usage

### Quality Metrics
- Unit test coverage: > 80%
- Crash-free rate: > 99.5%
- User rating goal: > 4.5 stars

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Location unavailable indoors | High | Medium | Use last known location, handle gracefully |
| Photos without EXIF | Medium | Low | Prompt for current location |
| Memory issues with large photos | Medium | High | Resize before processing |
| App Store rejection | Low | High | Follow HIG strictly, test thoroughly |
| Performance on older devices | Medium | Medium | Optimize, test on iPhone 11 |
| Permission denial by users | High | High | Clear explanations, graceful degradation |

---

## Future Enhancements (v2.0+)

1. **Multiple Photos**
   - Batch processing
   - Create photo collages

2. **Customization**
   - Multiple Polaroid styles
   - Custom fonts
   - Color schemes

3. **Metadata Options**
   - Weather information (if available)
   - Altitude display
   - Compass direction

4. **Export Options**
   - PDF generation
   - Different sizes
   - Print formatting

5. **Organization**
   - Albums/collections
   - Search by location
   - Map view of photos

6. **Widgets**
   - Quick capture widget
   - Recent photos widget

---

## Success Criteria

### Technical Success
- ✅ App works offline 100%
- ✅ Supports iPhone 11+
- ✅ Follows Apple HIG
- ✅ < 99.5% crash-free
- ✅ Passes App Store review

### User Success
- ✅ Easy to use (< 3 taps to create)
- ✅ Beautiful output
- ✅ Scannable QR codes
- ✅ Fast processing
- ✅ Reliable location capture

### Business Success
- ✅ App Store approval
- ✅ Positive reviews (4+ stars)
- ✅ Low support burden
- ✅ Potential for future features

---

## Resources & References

### Apple Documentation
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [AVFoundation Programming Guide](https://developer.apple.com/av-foundation/)
- [Core Location](https://developer.apple.com/documentation/corelocation)
- [Photos Framework](https://developer.apple.com/documentation/photokit)

### Code Examples
- Apple Sample Code: AVCam
- Apple Sample Code: PHPicker
- Core Image Filter Reference

### Design Resources
- SF Symbols App
- Apple Design Resources
- Color contrast checker

---

## Notes

- All dates are estimates and may vary based on complexity discovered during implementation
- Testing should be ongoing throughout development, not just in Phase 9
- User feedback during beta testing may require adjustments
- Keep code well-documented for future maintenance
- Follow Swift style guide and best practices
- Use Git for version control with meaningful commits
- Consider using SwiftLint for code quality

---

**Document Version**: 1.0
**Last Updated**: 2025-11-08
**Status**: Ready for Development
