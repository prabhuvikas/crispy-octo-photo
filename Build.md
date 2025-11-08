# PhotoLoc - Build & Deployment Guide

Complete guide for building PhotoLoc on macOS and Windows, and deploying to TestFlight.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Building on macOS](#building-on-macos)
- [Building on Windows](#building-on-windows)
- [TestFlight Deployment](#testflight-deployment)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts

1. **Apple ID**
   - Free Apple ID for development
   - Or Apple Developer Program membership ($99/year) for App Store/TestFlight

2. **Apple Developer Program** (Required for TestFlight)
   - Enroll at: https://developer.apple.com/programs/
   - Cost: $99 USD/year
   - Processing time: 24-48 hours

### Hardware Requirements

#### macOS (Recommended)
- **Mac computer** (MacBook, iMac, Mac Mini, or Mac Studio)
- **macOS 11.0 (Big Sur)** or later
- **8GB RAM** minimum (16GB recommended)
- **20GB free disk space**
- **iPhone** for physical device testing (iPhone 11 or newer)

#### Windows (Limited Support)
- **Windows 10/11** (64-bit)
- **16GB RAM** minimum
- **50GB free disk space** (for virtual machine)
- **iPhone** for physical device testing

---

## Building on macOS

### Step 1: Install Xcode

1. **Open App Store** on your Mac

2. **Search for "Xcode"**

3. **Click "Get" or "Install"**
   - Download size: ~12GB
   - Installation time: 30-60 minutes

4. **Launch Xcode**
   - First launch will install additional components
   - Accept the license agreement

5. **Verify Installation**
   ```bash
   xcodebuild -version
   ```
   Should show: `Xcode 13.0` or later

### Step 2: Install Command Line Tools

1. **Open Terminal** (Applications > Utilities > Terminal)

2. **Install Command Line Tools**:
   ```bash
   xcode-select --install
   ```

3. **Verify Installation**:
   ```bash
   xcode-select -p
   ```
   Should show: `/Applications/Xcode.app/Contents/Developer`

### Step 3: Clone the Repository

1. **Open Terminal**

2. **Navigate to desired location**:
   ```bash
   cd ~/Documents
   ```

3. **Clone the repository**:
   ```bash
   git clone https://github.com/prabhuvikas/crispy-octo-photo.git
   cd crispy-octo-photo
   ```

### Step 4: Create Xcode Project

Since this is a code-only repository, you need to create the Xcode project:

1. **Open Xcode**

2. **Create New Project**:
   - File > New > Project
   - Select **iOS** > **App**
   - Click **Next**

3. **Configure Project**:
   - **Product Name**: `PhotoLocApp`
   - **Team**: Select your Apple ID
   - **Organization Identifier**: `com.yourname` (use your domain or name)
   - **Bundle Identifier**: Will auto-generate (e.g., `com.yourname.PhotoLocApp`)
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: None
   - Click **Next**

4. **Save Location**:
   - Navigate to: `crispy-octo-photo/PhotoLocApp/`
   - Click **Create**

5. **Important**: Delete default files
   - Delete `ContentView.swift`
   - Delete `PhotoLocAppApp.swift` (if Xcode created it)

### Step 5: Add Project Files

1. **Add all source files** to the project:
   - In Xcode, right-click on the `PhotoLocApp` folder
   - Select **Add Files to "PhotoLocApp"...**
   - Navigate to `crispy-octo-photo/PhotoLocApp/PhotoLocApp/`
   - Select all folders: `Models`, `Views`, `ViewModels`, `Services`, `Utilities`
   - Also select `PhotoLocApp.swift` and `Info.plist`
   - **Important**: Check "Copy items if needed"
   - Click **Add**

2. **Verify file structure** in Xcode Project Navigator:
   ```
   PhotoLocApp/
   ├── PhotoLocApp.swift
   ├── Info.plist
   ├── Models/
   ├── Views/
   ├── ViewModels/
   ├── Services/
   └── Utilities/
   ```

### Step 6: Configure Project Settings

1. **Select Project** in Navigator (top-most item)

2. **General Tab**:
   - **Display Name**: PhotoLoc
   - **Bundle Identifier**: Ensure it matches (e.g., `com.yourname.PhotoLocApp`)
   - **Version**: 1.0
   - **Build**: 1
   - **Deployment Target**: iOS 14.0
   - **Supported Destinations**: iPhone only

3. **Signing & Capabilities**:
   - **Automatically manage signing**: ✅ Checked
   - **Team**: Select your Apple Developer Team
   - **Signing Certificate**: Automatically generated

4. **Info.plist Configuration**:
   - Verify permissions are present:
     - NSCameraUsageDescription
     - NSPhotoLibraryUsageDescription
     - NSPhotoLibraryAddUsageDescription
     - NSLocationWhenInUseUsageDescription
   - These should already be in the Info.plist file

5. **Build Settings**:
   - Click on "Build Settings" tab
   - Search for "Swift Language Version"
   - Ensure it's set to **Swift 5** or later

### Step 7: Build the Project

#### For Simulator (Quick Testing)

1. **Select Simulator**:
   - Click the device dropdown (top-left, next to Play button)
   - Select any iPhone (e.g., "iPhone 14 Pro")

2. **Build and Run**:
   - Press `⌘R` or click the Play button
   - Wait for build to complete (first build takes 1-2 minutes)

3. **Verify**:
   - App should launch in simulator
   - **Note**: Camera and GPS won't work in simulator

#### For Physical Device (Full Testing)

1. **Connect iPhone**:
   - Connect iPhone to Mac via USB cable
   - Unlock iPhone
   - Trust the computer (tap "Trust" on iPhone)

2. **Select Device**:
   - Click device dropdown in Xcode
   - Select your iPhone from the list

3. **Build and Run**:
   - Press `⌘R` or click Play
   - First time: May need to trust developer on iPhone
     - iPhone Settings > General > VPN & Device Management
     - Tap your Apple ID
     - Tap "Trust"

4. **Grant Permissions**:
   - When prompted, grant Camera, Photos, and Location permissions
   - Test all features

### Step 8: Archive for Distribution

1. **Select "Any iOS Device (arm64)"** from device dropdown

2. **Archive the App**:
   - Product > Archive
   - Wait for archive to complete (2-5 minutes)

3. **Organizer Window Opens**:
   - Shows your archive
   - Click **Distribute App**

4. **Distribution Method**:
   - Select **App Store Connect** (for TestFlight)
   - Click **Next**

5. **Distribution Options**:
   - Select **Upload**
   - Click **Next**

6. **App Store Distribution Options**:
   - Keep defaults
   - Click **Next**

7. **Signing**:
   - Select **Automatically manage signing**
   - Click **Next**

8. **Review**:
   - Review the summary
   - Click **Upload**

9. **Wait for Processing**:
   - Upload time: 5-15 minutes depending on connection
   - You'll receive an email when processing is complete

---

## Building on Windows

**Important**: iOS app development is officially only supported on macOS. However, there are workarounds:

### Option 1: macOS Virtual Machine (Recommended)

#### Requirements:
- **Windows 10/11 Pro** (Hyper-V support)
- **16GB RAM** minimum (32GB recommended)
- **50GB free disk space**
- **VMware Workstation** or **VirtualBox**

#### Steps:

1. **Download macOS Ventura ISO**:
   - Search for "macOS Ventura ISO" (legal gray area - use at own risk)
   - Or create from official installer

2. **Install VMware Workstation**:
   - Download from: https://www.vmware.com/products/workstation-player.html
   - Install and restart

3. **Create macOS VM**:
   - Open VMware
   - Create New Virtual Machine
   - Select macOS image
   - Allocate: 8GB RAM, 4 CPU cores, 60GB disk
   - Start VM and install macOS

4. **Install Xcode in VM**:
   - Follow macOS instructions above
   - Performance will be slower

5. **USB Passthrough** (for device testing):
   - VM > Removable Devices > iPhone
   - Connect to virtual machine

⚠️ **Limitations**:
- Slower performance
- May violate Apple's EULA (use for development only)
- USB passthrough can be unreliable

### Option 2: Cloud Mac Services (Paid)

#### MacStadium (Recommended)
- **Website**: https://www.macstadium.com/
- **Cost**: $79-$299/month
- **Features**: Remote Mac access, Xcode pre-installed

#### Steps:
1. Sign up for MacStadium account
2. Select plan (Mac Mini recommended)
3. Access via Remote Desktop
4. Follow macOS build instructions above

#### MacinCloud
- **Website**: https://www.macincloud.com/
- **Cost**: $30-$80/month
- **Features**: Pay-as-you-go option available

### Option 3: Use GitHub Actions (CI/CD)

For automated builds without a Mac:

1. **Create `.github/workflows/build.yml`**:
   ```yaml
   name: Build iOS App

   on: [push]

   jobs:
     build:
       runs-on: macos-latest

       steps:
       - uses: actions/checkout@v3

       - name: Setup Xcode
         uses: maxim-lobanov/setup-xcode@v1
         with:
           xcode-version: latest-stable

       - name: Build
         run: |
           cd PhotoLocApp
           xcodebuild -scheme PhotoLocApp -destination 'platform=iOS Simulator,name=iPhone 14' build
   ```

2. **Limitations**:
   - Can't test on physical device
   - 2000 free minutes/month
   - Not suitable for TestFlight uploads (requires certificates)

### Option 4: Borrow/Rent a Mac

- **Apple Store**: Book a session at Genius Bar
- **Friends**: Borrow a Mac temporarily
- **Co-working Spaces**: Some have Mac available
- **Universities**: Mac labs for students

---

## TestFlight Deployment

### Prerequisites

✅ **Apple Developer Program** membership ($99/year)
✅ **App successfully archived** (see Step 8 above)
✅ **App Store Connect** access

### Step 1: Create App in App Store Connect

1. **Go to App Store Connect**:
   - Visit: https://appstoreconnect.apple.com/
   - Sign in with your Apple ID

2. **Create New App**:
   - Click **My Apps**
   - Click **+** button > **New App**

3. **App Information**:
   - **Platform**: iOS
   - **Name**: PhotoLoc (or your chosen name)
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select the one you used in Xcode (e.g., `com.yourname.PhotoLocApp`)
   - **SKU**: photoloc-app-001 (any unique identifier)
   - **User Access**: Full Access
   - Click **Create**

### Step 2: Complete App Information

1. **App Information**:
   - **Subtitle**: "Location-Tagged Polaroid Photos"
   - **Privacy Policy URL**: (Create simple policy - see template below)
   - **Category**: Primary: Photo & Video

2. **Pricing and Availability**:
   - **Price**: Free
   - **Availability**: All countries

### Step 3: Upload Build

1. **Archive App** (if not done):
   - Follow "Step 8: Archive for Distribution" above
   - Upload to App Store Connect

2. **Wait for Processing**:
   - Processing time: 10-30 minutes
   - You'll receive email: "Your app [PhotoLoc] has been processed"

3. **Select Build**:
   - In App Store Connect, go to your app
   - Click **TestFlight** tab
   - Build should appear under "iOS Builds"
   - If not visible, wait or refresh page

### Step 4: Configure TestFlight

1. **Test Information**:
   - Click on build version (e.g., "1.0 (1)")
   - **What to Test**: "Initial beta release of PhotoLoc"
   - **Beta App Description**: Brief description of the app
   - **Feedback Email**: your-email@example.com
   - **Marketing URL**: (optional)
   - **Privacy Policy URL**: (required)
   - Click **Save**

2. **Export Compliance**:
   - Question: "Does your app use encryption?"
   - Answer: **No** (we're using standard iOS encryption only)
   - Click **Save**

### Step 5: Add Internal Testers

Internal testers can test immediately (no review required).

1. **Internal Testing Tab**:
   - Click **Internal Testing** (left sidebar)
   - Click **+** to create a group

2. **Create Test Group**:
   - **Group Name**: Internal Testers
   - Click **Create**

3. **Add Testers**:
   - Click **+** next to Testers
   - Add email addresses of testers
   - They must have Apple ID
   - Click **Add**

4. **Add Build**:
   - Click **+** next to Builds
   - Select your build
   - Click **Add**

5. **Testers Receive Email**:
   - Testers receive TestFlight invitation
   - They can install within minutes

### Step 6: Add External Testers (Optional)

External testers require App Review (1-2 days).

1. **External Testing Tab**:
   - Click **External Testing**
   - Click **+** to create a group

2. **Create Test Group**:
   - **Group Name**: Public Beta
   - **Enable public link**: (optional)
   - Click **Create**

3. **Add Testers**:
   - Add individual emails OR
   - Generate public link for anyone to join

4. **Add Build**:
   - Select build
   - Click **Submit for Review**

5. **Beta App Review Info**:
   - **First Name**: Your name
   - **Last Name**: Your name
   - **Email**: Your email
   - **Phone**: Your phone
   - **Sign-in Required**: No
   - **Notes**: "Please test photo capture and location tagging features"
   - Click **Submit**

6. **Wait for Approval**:
   - Review time: 12-48 hours
   - You'll receive email when approved

### Step 7: Install TestFlight on iPhone

1. **Install TestFlight App**:
   - Open App Store on iPhone
   - Search "TestFlight"
   - Install (free, by Apple)

2. **Open Invitation Email**:
   - Open TestFlight invite on iPhone
   - Tap "View in TestFlight"
   - Or enter redeem code manually

3. **Install PhotoLoc**:
   - Tap "Install" in TestFlight app
   - Accept terms
   - App installs like regular app

4. **App Icon**:
   - Orange dot appears on icon (indicates beta)
   - App appears on home screen

### Step 8: Test the App

#### Internal Testing Checklist:

✅ **Basic Functionality**:
- [ ] App launches without crashes
- [ ] Home screen displays correctly
- [ ] Settings screen opens

✅ **Permissions**:
- [ ] Camera permission prompt appears
- [ ] Photo library permission prompt appears
- [ ] Location permission prompt appears
- [ ] Can grant/deny permissions
- [ ] Settings link works if denied

✅ **Camera Capture**:
- [ ] Camera opens and shows preview
- [ ] Can capture photo
- [ ] Location is tagged (check coordinates)
- [ ] Photo processes correctly
- [ ] Polaroid style is applied
- [ ] QR code is generated and visible

✅ **Photo Selection**:
- [ ] Photo picker opens
- [ ] Can select photo from library
- [ ] EXIF location is extracted (if present)
- [ ] Falls back to current location if no EXIF
- [ ] Photo processes correctly

✅ **Polaroid Output**:
- [ ] White border is applied
- [ ] Bottom space shows QR code
- [ ] Location coordinates display correctly
- [ ] Timestamp displays correctly
- [ ] Description field works
- [ ] QR code scans correctly (use another phone's camera)

✅ **Save & Share**:
- [ ] Save to photo library works
- [ ] Photo appears in Photos app
- [ ] Share sheet works
- [ ] Can share to Messages, Mail, etc.

✅ **Settings**:
- [ ] Can change Polaroid style (Classic/Vintage/Modern)
- [ ] Toggle timestamp on/off
- [ ] Toggle coordinates on/off
- [ ] Auto-save toggle works
- [ ] Default description saves

✅ **Edge Cases**:
- [ ] Works in airplane mode (offline)
- [ ] Works without location permission (skips location)
- [ ] Works without camera permission (can still select photos)
- [ ] Handles photos without EXIF location
- [ ] Works in dark mode
- [ ] Works in landscape orientation
- [ ] Handles low memory (large photos)

✅ **Performance**:
- [ ] App launches in < 2 seconds
- [ ] Photo processing in < 3 seconds
- [ ] No crashes during normal use
- [ ] No UI freezes

### Step 9: Collect Feedback

1. **TestFlight Feedback**:
   - Testers can shake device to send feedback
   - Screenshot + feedback sent to you
   - Review in App Store Connect > TestFlight > Feedback

2. **Crash Reports**:
   - Automatic crash reporting
   - View in Xcode > Organizer > Crashes

3. **Iterate**:
   - Fix bugs
   - Create new build
   - Upload to TestFlight
   - Repeat testing

### Step 10: Promote to App Store (Optional)

Once testing is complete:

1. **Prepare App Store Listing**:
   - Screenshots (required sizes)
   - App description
   - Keywords
   - Privacy policy

2. **Submit for Review**:
   - In App Store Connect
   - Select build from TestFlight
   - Submit to App Review

3. **Review Time**:
   - 1-3 days typically
   - May have questions from reviewer

4. **Approval & Release**:
   - Approved apps go live immediately or scheduled
   - Available on App Store worldwide

---

## Privacy Policy Template

Create a simple `privacy.html` and host on GitHub Pages or your website:

```html
<!DOCTYPE html>
<html>
<head>
    <title>PhotoLoc Privacy Policy</title>
</head>
<body>
    <h1>PhotoLoc Privacy Policy</h1>
    <p>Last updated: [Current Date]</p>

    <h2>Data Collection</h2>
    <p>PhotoLoc does not collect, store, or transmit any user data.</p>

    <h2>Data Processing</h2>
    <p>All photo processing happens locally on your device. No data is sent to external servers.</p>

    <h2>Permissions</h2>
    <ul>
        <li><strong>Camera</strong>: Required to capture photos</li>
        <li><strong>Photo Library</strong>: Required to save and select photos</li>
        <li><strong>Location</strong>: Required to tag photos with GPS coordinates</li>
    </ul>

    <h2>Data Storage</h2>
    <p>All data remains on your device. We do not use analytics, tracking, or third-party services.</p>

    <h2>Contact</h2>
    <p>Email: your-email@example.com</p>
</body>
</html>
```

Host on GitHub Pages:
1. Create repository: `photoloc-privacy`
2. Add `privacy.html`
3. Enable GitHub Pages in Settings
4. URL: `https://yourusername.github.io/photoloc-privacy/privacy.html`

---

## Troubleshooting

### Build Errors

#### Error: "No signing certificate found"

**Solution**:
1. Xcode > Preferences > Accounts
2. Select your Apple ID
3. Click "Manage Certificates"
4. Click "+" > "Apple Development"
5. Close and rebuild

#### Error: "Bundle identifier already in use"

**Solution**:
1. Change Bundle Identifier in project settings
2. Use format: `com.yourname.PhotoLocApp`
3. Must be unique across App Store

#### Error: "Swift Compiler Error"

**Solution**:
1. Clean build folder: Product > Clean Build Folder (⌘⇧K)
2. Delete derived data: ~/Library/Developer/Xcode/DerivedData
3. Restart Xcode
4. Rebuild

#### Error: "Missing Info.plist keys"

**Solution**:
1. Ensure Info.plist is in project
2. Verify all NSUsageDescription keys are present
3. Check file is included in target

### Device Connection Issues

#### iPhone not appearing in Xcode

**Solution**:
1. Disconnect and reconnect USB cable
2. Trust computer on iPhone
3. Restart Xcode
4. Check cable (try different cable/port)
5. Update to latest iOS

#### "Could not launch app" error

**Solution**:
1. iPhone Settings > General > VPN & Device Management
2. Trust your developer certificate
3. Try again

### TestFlight Issues

#### Build not appearing after upload

**Solution**:
- Wait 15-30 minutes for processing
- Check email for errors
- Refresh page
- Verify build uploaded successfully in Xcode Organizer

#### Testers not receiving invitation

**Solution**:
- Check spam folder
- Verify email address is correct
- Resend invitation from App Store Connect
- Ensure tester's Apple ID matches email

#### "Export Compliance" missing

**Solution**:
- In TestFlight, click build
- Answer encryption questions
- Save

### Runtime Errors

#### Crash on launch

**Solution**:
1. Check device console in Xcode (Window > Devices and Simulators)
2. View crash logs
3. Common causes:
   - Missing file
   - Wrong Info.plist
   - iOS version mismatch

#### Permissions not working

**Solution**:
1. Delete app from device
2. Reinstall
3. Permissions reset on reinstall

#### Location not working

**Solution**:
- Test on physical device (not simulator)
- Ensure location services enabled in iPhone Settings
- Check permission is granted
- Try outdoors for better GPS signal

### Performance Issues

#### Slow photo processing

**Solution**:
- Test on newer device (iPhone 11+)
- Check image size (very large images take longer)
- Verify not running debug build (use release)

#### App using too much memory

**Solution**:
- Reduce max image dimension in Constants.swift
- Lower JPEG quality
- Test with smaller photos

---

## Best Practices

### Version Control

```bash
# Create meaningful commits
git commit -m "Fix camera orientation bug"

# Tag releases
git tag -a v1.0 -m "Version 1.0 - Initial release"
git push --tags
```

### Versioning

- **Version Number**: User-facing (1.0, 1.1, 2.0)
- **Build Number**: Internal (1, 2, 3, 4...)
- Increment build for each TestFlight upload
- Increment version for App Store releases

### Code Signing

- Keep certificates backed up
- Use Keychain Access to export
- Store securely

### Testing Workflow

1. Test in simulator (quick iteration)
2. Test on physical device (full features)
3. Upload to TestFlight (internal testing)
4. Fix bugs, upload new build
5. External testing (wider audience)
6. Submit to App Store

---

## Additional Resources

### Official Documentation

- **Apple Developer**: https://developer.apple.com/
- **Xcode Documentation**: https://developer.apple.com/xcode/
- **TestFlight**: https://developer.apple.com/testflight/
- **App Store Connect**: https://developer.apple.com/app-store-connect/
- **SwiftUI**: https://developer.apple.com/xcode/swiftui/

### Tutorials

- **Hacking with Swift**: https://www.hackingwithswift.com/
- **Ray Wenderlich**: https://www.raywenderlich.com/
- **Apple WWDC Videos**: https://developer.apple.com/videos/

### Community

- **Stack Overflow**: https://stackoverflow.com/questions/tagged/ios
- **Apple Developer Forums**: https://developer.apple.com/forums/
- **Reddit**: r/iOSProgramming

---

## Summary

### macOS Build (Recommended)
1. ✅ Install Xcode
2. ✅ Create project
3. ✅ Add files
4. ✅ Configure signing
5. ✅ Build & test
6. ✅ Archive & upload

### Windows Build (Limited)
1. ⚠️ Use VM or cloud Mac
2. ⚠️ Follow macOS steps
3. ⚠️ Expect slower performance

### TestFlight
1. ✅ Create App Store Connect app
2. ✅ Upload build
3. ✅ Add testers
4. ✅ Test thoroughly
5. ✅ Collect feedback
6. ✅ Iterate

---

**Questions?** Check troubleshooting section or file an issue on GitHub.

**Ready to build?** Start with macOS instructions above! 🚀
