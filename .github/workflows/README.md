# GitHub Actions Workflows

This directory contains automated CI/CD workflows for PhotoLoc iOS app.

## Workflows Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Actions CI/CD Pipeline                 │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  Developer       │
│  Creates PR      │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│  CI Workflow (ci.yml)                                           │
│  • Builds app for simulator                                     │
│  • Runs unit tests                                              │
│  • Reports status on PR                                         │
│  Duration: ~5-10 minutes                                        │
└─────────────────────────────────────────────────────────────────┘
         │
         │ ✅ Tests Pass
         ▼
┌──────────────────┐
│  PR Merged to    │
│  main branch     │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│  TestFlight Workflow (testflight.yml)                           │
│  • Builds release version                                       │
│  • Signs with distribution certificate                          │
│  • Creates IPA                                                  │
│  • Uploads to App Store Connect                                │
│  • Available on TestFlight                                      │
│  Duration: ~15-25 minutes                                       │
└─────────────────────────────────────────────────────────────────┘
         │
         │ 📱 Beta Testing
         ▼
┌──────────────────┐
│  Tag Release     │
│  (v1.0.0)        │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│  App Store Workflow (appstore.yml)                              │
│  • Builds release version                                       │
│  • Updates version number from tag                              │
│  • Creates IPA                                                  │
│  • Uploads to App Store Connect                                │
│  • Creates GitHub release                                       │
│  • Ready for App Store submission                               │
│  Duration: ~15-25 minutes                                       │
└─────────────────────────────────────────────────────────────────┘
         │
         │ 🚀 Production
         ▼
┌──────────────────┐
│  App Store       │
│  (Live)          │
└──────────────────┘
```

## Workflow Files

### 1. `ci.yml` - Continuous Integration

**Triggers:**
- Pull requests to `main` or `develop`
- Pushes to `main` or `develop`

**Actions:**
- Checkout code
- Select Xcode version
- Build for iOS simulator
- Run unit tests
- Upload build artifacts

**Status:** Always runs, provides feedback on PRs

---

### 2. `testflight.yml` - TestFlight Deployment

**Triggers:**
- Push to `main` branch (automatic)
- Push to `release/*` branches (automatic)
- Manual dispatch via Actions tab

**Actions:**
- Import signing certificates
- Build release archive
- Export IPA
- Upload to App Store Connect
- Notify completion

**Result:** Build available on TestFlight in 30 minutes

---

### 3. `appstore.yml` - App Store Deployment

**Triggers:**
- Version tags: `v1.0.0`, `v1.2.3`, etc.
- Manual dispatch via Actions tab

**Actions:**
- Extract version from tag
- Update app version number
- Build and sign release
- Upload to App Store Connect
- Create GitHub release
- Optionally submit for review

**Result:** Build ready for App Store submission

---

## Usage Examples

### Daily Development

```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"
git push origin feature/new-feature

# Create PR - CI runs automatically ✅
```

### Deploy to TestFlight

```bash
# Option 1: Automatic (merge PR to main)
git checkout main
git merge feature/new-feature
git push origin main
# TestFlight workflow starts automatically 🚀

# Option 2: Manual trigger
# Go to Actions tab > "Deploy to TestFlight" > Run workflow
```

### Deploy to App Store

```bash
# Create and push version tag
git tag -a v1.0.0 -m "Version 1.0 - Initial Release"
git push origin v1.0.0
# App Store workflow starts automatically 🎉

# Check release at: github.com/<user>/<repo>/releases
```

---

## Required Secrets

Configure these in Settings > Secrets and variables > Actions:

| Secret | Description |
|--------|-------------|
| `APPLE_TEAM_ID` | Your Apple Developer Team ID |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Base64-encoded .p12 certificate |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Certificate password |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded provisioning profile |
| `PROVISIONING_PROFILE_NAME` | Exact provisioning profile name |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | API Issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Base64-encoded .p8 API key |
| `KEYCHAIN_PASSWORD` | Random password for build keychain |

**Setup Guide:** See [CI-CD-SETUP.md](../../CI-CD-SETUP.md)

---

## Monitoring Builds

### View Workflow Status

1. Go to **Actions** tab in GitHub
2. See all workflow runs
3. Click on run for details
4. View logs for each step

### Status Badges

Add to README:

```markdown
![CI](https://github.com/<user>/<repo>/workflows/iOS%20CI%20-%20Build%20&%20Test/badge.svg)
![TestFlight](https://github.com/<user>/<repo>/workflows/Deploy%20to%20TestFlight/badge.svg)
![App Store](https://github.com/<user>/<repo>/workflows/Deploy%20to%20App%20Store/badge.svg)
```

---

## Troubleshooting

### Build Fails

1. Check workflow logs in Actions tab
2. Verify all secrets are correctly set
3. Ensure certificates haven't expired
4. Check Xcode version compatibility

### TestFlight Upload Fails

1. Verify API key is valid
2. Check bundle ID matches
3. Ensure app exists in App Store Connect
4. Review export compliance settings

### Need Help?

See [CI-CD-SETUP.md](../../CI-CD-SETUP.md) for complete troubleshooting guide.

---

## Customization

### Change Xcode Version

```yaml
- name: Select Xcode version
  run: sudo xcode-select -s /Applications/Xcode_15.0.app/Contents/Developer
```

### Add Slack Notifications

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Run Only on Specific Branches

```yaml
on:
  push:
    branches:
      - main
      - release/*
```

---

## Cost

**GitHub Actions Free Tier:**
- 2,000 minutes/month for private repos
- Unlimited for public repos

**macOS Runner Multiplier:**
- 10x (10 min build = 100 min usage)

**Estimated Usage:**
- CI build: ~50 minutes/run
- TestFlight deploy: ~200 minutes/run
- ~10 builds/day = FREE on free tier

---

## Best Practices

✅ **DO:**
- Keep secrets secure and rotate regularly
- Use caching to speed up builds
- Monitor build times and optimize
- Test workflows on feature branches first

❌ **DON'T:**
- Commit certificates or keys to repo
- Skip code signing validation
- Deploy directly to production without TestFlight
- Ignore failed builds

---

**Ready to deploy?** See [CI-CD-SETUP.md](../../CI-CD-SETUP.md) for complete setup instructions! 🚀
