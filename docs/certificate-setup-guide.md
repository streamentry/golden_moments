# Certificate Generation Setup Guide for Golden Moments

## Step-by-Step Setup Instructions

### Step 1: Create Private Certificate Repository

First, create a private repository to store your certificates:

```bash
# Go to GitHub and create a new PRIVATE repository
# Repository name: golden-moments-certificates
# Make sure it's set to PRIVATE for security
```

### Step 2: Install Ruby and Fastlane

On your local Mac (required for certificate generation):

```bash
# Install Ruby (if not already installed)
brew install ruby

# Install Fastlane
gem install fastlane

# Navigate to your project
cd d:\Code\golden_moments\ios
```

### Step 3: Set Up Environment Variables

Create a local environment file:

```bash
# Copy the template
cp .env.template .env

# Edit .env with your actual values:
# APPLE_ID=your-apple-id@example.com
# DEVELOPER_PORTAL_TEAM_ID=YOUR_ACTUAL_TEAM_ID
# APP_STORE_CONNECT_TEAM_ID=YOUR_ACTUAL_TEAM_ID
# MATCH_PASSWORD=choose-a-secure-password
```

**Important:** Never commit the `.env` file to version control!

### Step 4: Find Your Team IDs

#### Developer Portal Team ID:

1. Go to https://developer.apple.com
2. Sign in with your Apple ID
3. Go to "Membership" in the sidebar
4. Your Team ID is displayed (10 characters, like ABC123DEF4)

#### App Store Connect Team ID:

1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple ID
3. Click your name in the top right
4. Select "View Membership"
5. Your Provider ID is your App Store Connect Team ID

### Step 5: Initialize Certificate Generation

Run these commands from the `ios` directory:

```bash
cd d:\Code\golden_moments\ios

# Initialize Match (first time only)
fastlane match init
# When prompted, enter: https://github.com/cschanhniem/golden-moments-certificates.git

# Generate development certificates
fastlane match development --verbose

# Generate App Store certificates
fastlane match appstore --verbose

# Or use the combined lane
fastlane certificates
```

### Step 6: Set Up Codemagic Environment Variables

In your Codemagic dashboard:

1. Go to your Golden Moments project
2. Navigate to Settings > Environment variables
3. Create a new group called `fastlane_env`
4. Add these variables:

```bash
# Group: fastlane_env
APPLE_ID=your-apple-id@example.com
DEVELOPER_PORTAL_TEAM_ID=ABC123DEF4
APP_STORE_CONNECT_TEAM_ID=123456789
MATCH_PASSWORD=your-chosen-password
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx

# App Store Connect API Key (when you get it)
APP_STORE_CONNECT_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
APP_STORE_CONNECT_KEY_IDENTIFIER=XXXXXXXXXX
APP_STORE_CONNECT_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----...-----END PRIVATE KEY-----
```

### Step 7: Create App-Specific Password

For the `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`:

1. Go to https://appleid.apple.com
2. Sign in with your Apple ID
3. Go to "Security" section
4. Generate an App-Specific Password
5. Label it "Fastlane" or "Golden Moments CI"
6. Copy the generated password

### Step 8: Test Certificate Generation

Run a test to ensure everything works:

```bash
cd d:\Code\golden_moments\ios

# Test certificate sync
fastlane sync_certificates --verbose

# Test build (this will use the certificates)
fastlane build_appstore
```

### Step 9: Register Bundle Identifier

Make sure your app's bundle ID is registered:

1. Go to https://developer.apple.com
2. Navigate to "Certificates, Identifiers & Profiles"
3. Select "Identifiers" > "App IDs"
4. Register `com.mindfulness.golden_moments` if not already done

### Step 10: Verify Setup

Push a commit to your repository to trigger the Codemagic build:

```bash
# Commit your changes
git add .
git commit -m "feat: add fastlane configuration for automated certificate management"
git push origin feat/hao/ios_build
```

## Troubleshooting Common Issues

### Issue: "No signing certificate found"

**Solution:** Run `fastlane match development` and `fastlane match appstore` locally first.

### Issue: "Invalid team ID"

**Solution:** Double-check your team IDs in both Apple Developer Portal and App Store Connect.

### Issue: "Repository not found"

**Solution:** Ensure the certificate repository is private and accessible with your Apple ID.

### Issue: "Fastlane not found"

**Solution:** Install Ruby and Fastlane: `gem install fastlane`

### Issue: "Bundle identifier not registered"

**Solution:** Register `com.mindfulness.golden_moments` in Apple Developer Portal.

## What This Setup Provides

✅ **Automated Certificate Management**: Certificates are created and stored securely  
✅ **Team Collaboration**: Multiple developers can use the same certificates  
✅ **Version Control**: Certificate history and rollback capability  
✅ **CI/CD Integration**: Seamless builds in Codemagic  
✅ **Security**: Encrypted storage of sensitive materials  
✅ **Consistency**: Same certificates across all environments

## Next Steps After Setup

1. **Generate App Store Connect API Key** (you found the UI for this)
2. **Test local builds** with `fastlane build_appstore`
3. **Trigger Codemagic build** to verify CI/CD works
4. **Upload to TestFlight** with `fastlane testflight`

The certificates will be automatically generated and stored in your private repository, ready for use by both local development and CI/CD systems.
