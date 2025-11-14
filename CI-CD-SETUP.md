# CI/CD Setup Guide - GitHub Actions for iOS

Complete guide to set up automated builds and deployments to TestFlight and App Store using GitHub Actions.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Workflows Explained](#workflows-explained)
4. [Setup Steps](#setup-steps)
5. [GitHub Secrets Configuration](#github-secrets-configuration)
6. [Testing the Workflows](#testing-the-workflows)
7. [Usage](#usage)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This repository includes three automated workflows:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **CI** (`ci.yml`) | Pull requests, pushes to main/develop | Build and test the app |
| **TestFlight** (`testflight.yml`) | Push to main, manual trigger | Deploy beta builds to TestFlight |
| **App Store** (`appstore.yml`) | Version tags (v1.0.0), manual trigger | Deploy production builds to App Store |

**Benefits:**
- ✅ Automated builds on every PR/merge
- ✅ Automatic TestFlight deployment on merge to main
- ✅ One-click App Store releases
- ✅ No need for local Mac (runs on GitHub's macOS runners)
- ✅ Consistent builds every time
- ✅ Version management and tagging

---

## Prerequisites

### 1. Apple Developer Program Membership
- **Cost**: $99/year
- **Sign up**: https://developer.apple.com/programs/

### 2. App Store Connect Access
- Access to App Store Connect with Admin or App Manager role
- App must be created in App Store Connect

### 3. GitHub Repository
- Admin access to configure secrets
- Actions enabled (default for most repos)

### 4. Local Mac (One-time setup)
- Only needed for initial certificate creation
- Can use borrowed/rented Mac

---

## Workflows Explained

### 1. CI Workflow (`ci.yml`)

**When it runs:**
- On pull requests to `main` or `develop`
- On pushes to `main` or `develop`

**What it does:**
1. Checks out code
2. Selects Xcode version
3. Builds app for simulator
4. Runs unit tests (if available)
5. Uploads build artifacts
6. Reports success/failure

**Typical duration:** 5-10 minutes

---

### 2. TestFlight Workflow (`testflight.yml`)

**When it runs:**
- Automatically on push to `main` branch
- Automatically on push to `release/*` branches
- Manually via "Actions" tab in GitHub

**What it does:**
1. Builds release version of app
2. Signs with distribution certificate
3. Creates IPA file
4. Uploads to App Store Connect
5. Makes available on TestFlight
6. Sends notification

**Typical duration:** 15-25 minutes

**Result:** Build available for internal testing within 30 minutes

---

### 3. App Store Workflow (`appstore.yml`)

**When it runs:**
- Automatically when you push a version tag (e.g., `v1.0.0`)
- Manually via "Actions" tab

**What it does:**
1. Extracts version from tag
2. Updates app version number
3. Builds release version
4. Signs and exports IPA
5. Uploads to App Store Connect
6. Optionally submits for review
7. Creates GitHub release

**Typical duration:** 15-25 minutes

**Result:** Build ready for App Store review

---

## Setup Steps

### Step 1: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com/
2. Click **My Apps** > **+** > **New App**
3. Fill in details:
   - **Platform**: iOS
   - **Name**: PhotoLoc
   - **Primary Language**: English
   - **Bundle ID**: Create new (e.g., `com.yourname.PhotoLocApp`)
   - **SKU**: photoloc-001
4. Click **Create**

### Step 2: Generate App Store Connect API Key

This allows GitHub Actions to upload builds without your password.

1. Go to **App Store Connect** > **Users and Access** > **Keys** tab
2. Click **+** to create new key
3. **Name**: GitHub Actions
4. **Access**: Developer (or App Manager)
5. Click **Generate**
6. **Download** the API Key file (`AuthKey_XXXXXXXXXX.p8`)
7. Note the **Key ID** and **Issuer ID**

⚠️ **Important**: Save the `.p8` file securely - you can only download it once!

### Step 3: Create Distribution Certificate

#### Option A: Using Xcode (Recommended)

1. Open Xcode
2. Go to **Xcode** > **Preferences** > **Accounts**
3. Select your Apple ID
4. Click **Manage Certificates**
5. Click **+** > **Apple Distribution**
6. Certificate is created automatically

#### Option B: Using Terminal

```bash
# Create certificate signing request
openssl req -nodes -newkey rsa:2048 -keyout PhotoLoc.key -out PhotoLoc.csr

# Upload CSR to developer.apple.com and download certificate
# Then create P12 file:
openssl x509 -in ios_distribution.cer -inform DER -out ios_distribution.pem -outform PEM
openssl pkcs12 -export -inkey PhotoLoc.key -in ios_distribution.pem -out ios_distribution.p12 -password pass:YOUR_PASSWORD
```

#### Export Certificate

1. Open **Keychain Access** app (macOS)
2. Select **My Certificates** in left sidebar
3. Find **Apple Distribution: Your Name (Team ID)**
4. Right-click > **Export**
5. Save as `.p12` file
6. Set a **password** (remember this!)

### Step 4: Create Provisioning Profile

1. Go to https://developer.apple.com/account/resources/profiles/
2. Click **+** to create new profile
3. Select **App Store** distribution
4. Select your **App ID** (Bundle ID)
5. Select your **Distribution Certificate**
6. **Name**: PhotoLoc App Store
7. Click **Generate** and **Download**

### Step 5: Convert Certificates to Base64

GitHub Secrets need to be base64 encoded.

#### On macOS/Linux:

```bash
# Convert distribution certificate
base64 -i ios_distribution.p12 -o certificate.txt

# Convert provisioning profile
base64 -i PhotoLoc_AppStore.mobileprovision -o profile.txt

# Convert API key
base64 -i AuthKey_XXXXXXXXXX.p8 -o apikey.txt
```

#### On Windows (PowerShell):

```powershell
# Convert distribution certificate
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ios_distribution.p12")) | Out-File certificate.txt

# Convert provisioning profile
[Convert]::ToBase64String([IO.File]::ReadAllBytes("PhotoLoc_AppStore.mobileprovision")) | Out-File profile.txt

# Convert API key
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_XXXXXXXXXX.p8")) | Out-File apikey.txt
```

### Step 6: Add Secrets to GitHub

1. Go to your GitHub repository
2. Click **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret** for each:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `APPLE_TEAM_ID` | Your Team ID | App Store Connect > Membership |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Base64 of `.p12` file | Step 5 output |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Certificate password | Password you set in Step 3 |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of `.mobileprovision` | Step 5 output |
| `PROVISIONING_PROFILE_NAME` | Profile name | Exact name from developer.apple.com |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID | From Step 2 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID | From Step 2 |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Base64 of `.p8` file | Step 5 output |
| `KEYCHAIN_PASSWORD` | Any random password | Generate strong password |

**Example:**

```
APPLE_TEAM_ID: ABC123DEF4
IOS_DISTRIBUTION_CERTIFICATE_BASE64: MIIKxAIBAzCCCnwGCSqGSIb3DQE...
IOS_DISTRIBUTION_CERTIFICATE_PASSWORD: MySecureP@ssw0rd
IOS_PROVISIONING_PROFILE_BASE64: MIIOuwYJKoZIhvcNAQcCoIIOrDC...
PROVISIONING_PROFILE_NAME: PhotoLoc App Store
APP_STORE_CONNECT_API_KEY_ID: ABC12XYZ34
APP_STORE_CONNECT_API_ISSUER_ID: 12345678-1234-1234-1234-123456789012
APP_STORE_CONNECT_API_KEY_CONTENT: LS0tLS1CRUdJTiBQUklWQVRF...
KEYCHAIN_PASSWORD: Th1sIsMyK3ych@inP@ss
```

### Step 7: Update Xcode Project

Update the following files with your actual values:

1. **Bundle Identifier** in Xcode:
   - Open `PhotoLocApp.xcodeproj`
   - Select target > General
   - Set Bundle Identifier (e.g., `com.yourname.PhotoLocApp`)

2. **Team** in Xcode:
   - Select target > Signing & Capabilities
   - Select your Team

3. **Fastlane Appfile** (if using fastlane):
   ```ruby
   # PhotoLocApp/fastlane/Appfile
   app_identifier "com.yourname.PhotoLocApp"
   apple_id "your-email@example.com"
   team_id "ABC123DEF4"
   ```

---

## Testing the Workflows

### Test CI Workflow

1. Create a new branch:
   ```bash
   git checkout -b test-ci
   ```

2. Make a small change (e.g., update README)

3. Push and create pull request:
   ```bash
   git add .
   git commit -m "Test CI workflow"
   git push origin test-ci
   ```

4. Create PR on GitHub
5. Watch the **Checks** tab - CI should run automatically
6. Should complete in ~5-10 minutes

### Test TestFlight Workflow

#### Option 1: Merge to Main (Automatic)

1. Merge a PR to `main` branch
2. Workflow starts automatically
3. Check **Actions** tab to monitor progress

#### Option 2: Manual Trigger

1. Go to **Actions** tab
2. Select **Deploy to TestFlight**
3. Click **Run workflow**
4. Select branch
5. Click **Run workflow**

### Test App Store Workflow

1. Ensure code is ready for release
2. Create and push version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. Workflow starts automatically
4. Monitor in **Actions** tab

---

## Usage

### Daily Development

```bash
# Make changes
git checkout -b feature/my-feature
# ... code ...
git add .
git commit -m "Add new feature"
git push origin feature/my-feature

# Create PR - CI runs automatically
# After review, merge to main - TestFlight deploys automatically
```

### Release to TestFlight

**Automatic** (recommended):
```bash
# Merge PR to main
git checkout main
git pull
# TestFlight deployment starts automatically
```

**Manual**:
1. Go to GitHub Actions tab
2. Select "Deploy to TestFlight"
3. Click "Run workflow"
4. Wait 15-25 minutes

### Release to App Store

```bash
# Create version tag
git tag -a v1.0.0 -m "Version 1.0.0 - Initial Release"
git push origin v1.0.0

# Or for pre-releases:
git tag -a v1.0.0-beta.1 -m "Beta 1"
git push origin v1.0.0-beta.1
```

### Check Build Status

1. Go to repository **Actions** tab
2. See all workflow runs
3. Click on a run to see details
4. View logs for each step

---

## Workflow Triggers Summary

| Action | Triggers | Result |
|--------|----------|--------|
| Create PR | CI Workflow | Build & test |
| Push to PR branch | CI Workflow | Build & test |
| Merge to `main` | CI + TestFlight Workflows | Build, test, deploy to TestFlight |
| Push to `release/*` | TestFlight Workflow | Deploy to TestFlight |
| Create tag `v*.*.*` | App Store Workflow | Deploy to App Store |
| Manual dispatch | Any workflow | Run on-demand |

---

## Fastlane Integration (Optional)

If you prefer using fastlane locally:

### Install Fastlane

```bash
# Using RubyGems
sudo gem install fastlane -NV

# Using Homebrew
brew install fastlane
```

### Initialize Fastlane

```bash
cd PhotoLocApp
fastlane init
```

### Use Fastlane Lanes

```bash
# Build for testing
fastlane build

# Run tests
fastlane test

# Deploy to TestFlight
fastlane beta

# Deploy to App Store
fastlane release
```

### Fastlane + GitHub Actions

The workflows can use fastlane commands instead of raw xcodebuild. Just uncomment the fastlane sections in the workflow files.

---

## Troubleshooting

### Build Fails: "No signing identity found"

**Cause**: Certificate or provisioning profile issues

**Solution**:
1. Verify secrets are correctly base64 encoded
2. Check certificate hasn't expired
3. Ensure provisioning profile matches bundle ID
4. Regenerate certificate if needed

### Build Fails: "Invalid API Key"

**Cause**: App Store Connect API key issues

**Solution**:
1. Verify API Key ID and Issuer ID are correct
2. Ensure `.p8` file content is base64 encoded correctly
3. Check API key hasn't been revoked
4. Regenerate API key if needed

### Upload Fails: "Invalid IPA"

**Cause**: Code signing or export issues

**Solution**:
1. Check provisioning profile includes distribution certificate
2. Verify bundle ID matches everywhere
3. Ensure Xcode version supports your deployment target
4. Check for deprecated APIs

### Workflow Doesn't Start

**Cause**: GitHub Actions may be disabled or workflow file has errors

**Solution**:
1. Check Settings > Actions > General (ensure Actions are enabled)
2. Validate YAML syntax (use YAML validator)
3. Check branch protection rules
4. Look for errors in Actions tab

### TestFlight Not Receiving Build

**Cause**: Upload succeeded but processing failed

**Solution**:
1. Wait 30-60 minutes (processing can be slow)
2. Check email for errors from Apple
3. Log into App Store Connect > TestFlight
4. Look for build with red warning icon
5. Check build compliance issues

### Build Number Conflict

**Cause**: Build number already used

**Solution**:
1. Workflows auto-increment build numbers
2. If manual, check latest build in App Store Connect
3. Increment manually in Info.plist

---

## Security Best Practices

### Secrets Management

✅ **DO:**
- Use GitHub Secrets for all sensitive data
- Rotate API keys every 6 months
- Use environment-specific secrets
- Limit secret access to necessary workflows

❌ **DON'T:**
- Commit certificates or keys to repo
- Share secrets in public channels
- Use same password across environments
- Store secrets in code or logs

### Certificate Management

- **Backup certificates**: Export and store securely (encrypted)
- **Set expiration reminders**: Certificates expire annually
- **Document process**: Keep setup instructions updated
- **Revoke compromised certs**: Immediately if exposed

---

## Advanced Configuration

### Custom Deployment Environments

Create separate workflows for staging/production:

```yaml
# .github/workflows/staging.yml
on:
  push:
    branches: [ staging ]

# .github/workflows/production.yml
on:
  push:
    tags: [ 'v*.*.*' ]
```

### Slack Notifications

Add notification step:

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Deployment completed'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Automated Screenshots

Use fastlane snapshot:

```ruby
# Fastfile
lane :screenshots do
  snapshot
end
```

```yaml
# In workflow
- name: Generate Screenshots
  run: fastlane screenshots
```

---

## Cost Considerations

### GitHub Actions Pricing

**Free tier:**
- 2,000 minutes/month for private repos
- Unlimited for public repos

**macOS runners:**
- 10x multiplier (10 minutes build = 100 minutes usage)
- Average CI build: 50 minutes usage
- Average TestFlight deploy: 200 minutes usage

**Cost estimate** (private repo):
- ~10 builds/day = ~2,000 minutes/month = **FREE**
- >20 builds/day = Need paid plan ($4/month)

**Tips to reduce usage:**
- Only run on necessary branches
- Cache dependencies
- Run tests in parallel
- Use self-hosted runners for heavy usage

---

## Monitoring & Maintenance

### Regular Checks

**Weekly:**
- Review failed builds
- Check TestFlight feedback
- Monitor build times

**Monthly:**
- Review GitHub Actions usage
- Check certificate expiration dates
- Update dependencies

**Quarterly:**
- Rotate API keys
- Audit secrets
- Update workflows

### Metrics to Track

- Build success rate
- Average build time
- TestFlight adoption rate
- Crash-free rate
- Review times

---

## Additional Resources

### Official Documentation

- [GitHub Actions for iOS](https://docs.github.com/en/actions/guides/building-and-testing-swift)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [Xcode Cloud](https://developer.apple.com/xcode-cloud/) (Apple's alternative)

### Tutorials

- [Ray Wenderlich: iOS CI/CD](https://www.raywenderlich.com/1774995-continuous-integration-and-delivery-for-ios-with-github-actions)
- [Fastlane Getting Started](https://docs.fastlane.tools/getting-started/ios/setup/)

### Community

- [GitHub Actions Community](https://github.community/c/github-actions/41)
- [Fastlane Community](https://github.com/fastlane/fastlane/discussions)

---

## Summary

✅ **Setup Checklist**:
- [ ] Apple Developer Program membership
- [ ] App created in App Store Connect
- [ ] App Store Connect API key generated
- [ ] Distribution certificate created and exported
- [ ] Provisioning profile created and downloaded
- [ ] All files converted to base64
- [ ] GitHub secrets configured
- [ ] Xcode project updated with correct Bundle ID
- [ ] Test CI workflow with PR
- [ ] Test TestFlight workflow
- [ ] Monitor first deployment

🚀 **You're Ready!**

Once setup is complete, your workflow will be:
1. Write code
2. Create PR (CI runs automatically)
3. Merge to main (TestFlight deploys automatically)
4. Tag release (App Store ready for submission)

All without touching Xcode! 🎉

---

**Questions?** Check the troubleshooting section or open an issue on GitHub.
