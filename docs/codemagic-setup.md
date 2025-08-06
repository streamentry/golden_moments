# Codemagic Setup Guide for Golden Moments

This guide will help you set up Codemagic CI/CD for the Golden Moments Flutter project.

## 📋 Prerequisites

Before setting up Codemagic, ensure you have:

1. **Codemagic Account**: Sign up at [codemagic.io](https://codemagic.io)
2. **Repository Access**: Your GitHub/GitLab/Bitbucket repository
3. **Signing Certificates**: Android keystore and iOS certificates
4. **Store Accounts**: Google Play Console and App Store Connect accounts

## 🚀 Getting Started

### 1. Connect Your Repository

1. Log in to Codemagic
2. Click "Add application from repository"
3. Select your Git provider (GitHub/GitLab/Bitbucket)
4. Choose the `golden_moments` repository
5. Select the branch to set up (usually `main` or `master`)

### 2. Configure Environment Variables

In Codemagic dashboard, go to your app settings and add these environment variables:

#### Firebase Configuration
```
FIREBASE_TOKEN=your_firebase_token_here
```

#### Google Play Store (for Android publishing)
```
GCLOUD_SERVICE_ACCOUNT_CREDENTIALS=your_service_account_json_content
```

#### App Store Connect (for iOS publishing)
```
APP_STORE_CONNECT_ISSUER_ID=your_issuer_id
APP_STORE_CONNECT_KEY_IDENTIFIER=your_key_identifier
APP_STORE_CONNECT_PRIVATE_KEY=your_private_key_content
```

### 3. Android Signing Setup

#### Upload Your Keystore
1. Go to "Code signing identities" in your app settings
2. Click "Android keystores"
3. Upload your keystore file (`keystore.jks`)
4. Provide the keystore details:
   - **Keystore password**
   - **Key alias** (usually from your `key.properties`)
   - **Key password**

#### Update Your Build Configuration
Your `android/app/build.gradle` is already configured to use environment variables for signing:
```gradle
signingConfigs {
    if (System.getenv("ANDROID_KEYSTORE_PATH")) {
        release {
            storeFile file(System.getenv("ANDROID_KEYSTORE_PATH"))
            keyAlias System.getenv("ANDROID_KEYSTORE_ALIAS")
            keyPassword System.getenv("ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD")
            storePassword System.getenv("ANDROID_KEYSTORE_PASSWORD")
        }
    }
    // ... local fallback
}
```

### 4. iOS Signing Setup

#### Automatic Code Signing
1. Go to "Code signing identities" in your app settings
2. Click "iOS certificates"
3. Choose "Automatic" for easier setup
4. Codemagic will handle provisioning profiles automatically

#### Manual Code Signing (Advanced)
If you prefer manual setup:
1. Upload your distribution certificate (.p12 file)
2. Upload your provisioning profiles
3. Configure the bundle identifier: `com.mindfulness.golden_moments`

## 🔧 Configuration Details

### Workflow Overview

The `codemagic.yaml` includes three workflows:

#### 1. Development Workflow
- **Triggers**: Any branch except main/master
- **Builds**: Development flavor APK and iOS
- **Publishing**: Firebase App Distribution for testing

#### 2. Production Workflow  
- **Triggers**: main/master branch pushes and tags
- **Builds**: Production flavor APK, AAB, and iOS
- **Publishing**: Google Play (internal testing) and TestFlight

#### 3. Pull Request Workflow
- **Triggers**: Pull requests
- **Scope**: Code analysis and testing only
- **Purpose**: Quality checks before merging

### Build Flavors

Your project supports multiple flavors:
- **development**: `com.mindfulness.golden_moments` (DEV)
- **staging**: `com.mindfulness.golden_moments.stg` (STG)  
- **production**: `com.mindfulness.golden_moments` (Production)

### Instance Types

- **mac_mini_m1**: Recommended for iOS builds and faster performance
- **mac_mini**: Alternative for iOS builds
- **linux**: For Android-only builds (faster and cheaper)

## 📱 Publishing Configuration

### Firebase App Distribution

For development builds, update the Firebase app IDs in `codemagic.yaml`:

```yaml
firebase:
  firebase_token: $FIREBASE_TOKEN
  android:
    app_id: your_android_firebase_app_id
    groups:
      - testers
  ios:
    app_id: your_ios_firebase_app_id
    groups:
      - testers
```

### Google Play Store

For production Android builds:
1. Create a service account in Google Cloud Console
2. Enable Google Play Developer API
3. Download the JSON key file
4. Add the JSON content as `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` environment variable

### Apple App Store

For production iOS builds:
1. Create an App Store Connect API key
2. Note down the Issuer ID and Key ID
3. Download the private key file
4. Add these as environment variables in Codemagic

## 🧪 Testing Configuration

The workflows include:
- **Flutter analyze**: Static code analysis
- **Flutter test**: Unit and widget tests
- **Code formatting check**: Dart format validation
- **Coverage reporting**: Test coverage analysis (production only)

## 🔍 Monitoring and Notifications

### Email Notifications
- **Recipients**: Update email addresses in the `publishing.email.recipients` section
- **Success notifications**: Enabled for development and production
- **Failure notifications**: Enabled for all workflows

### Build Artifacts
Saved artifacts include:
- APK/AAB files
- iOS IPA files
- Mapping files (for crash analysis)
- Build logs
- Coverage reports

## 🚨 Troubleshooting

### Common Issues

1. **Flutter version mismatch**
   - Update `FLUTTER_VERSION` in environment variables
   - Ensure it matches your local Flutter version

2. **Build failures due to dependencies**
   - Run `flutter packages pub get` locally first
   - Check for any platform-specific dependency issues

3. **Signing issues**
   - Verify keystore passwords and aliases
   - Check certificate expiration dates
   - Ensure bundle identifiers match

4. **Firebase configuration**
   - Verify `google-services.json` is in `android/app/`
   - Check Firebase project settings
   - Ensure Firebase CLI token is valid

### Getting Help

- **Codemagic Documentation**: [docs.codemagic.io](https://docs.codemagic.io)
- **Flutter CI/CD Guide**: [docs.codemagic.io/flutter-projects](https://docs.codemagic.io/flutter-projects/)
- **Support**: Contact Codemagic support through their dashboard

## 📈 Next Steps

1. **Test the Setup**: Push a commit to trigger your first build
2. **Monitor Builds**: Check the Codemagic dashboard for build progress
3. **Optimize**: Adjust build scripts and workflows based on your needs
4. **Scale**: Add more sophisticated testing and deployment strategies

## 🔐 Security Best Practices

- Never commit sensitive credentials to your repository
- Use Codemagic's secure environment variables for secrets
- Regularly rotate API keys and certificates
- Review and audit team access permissions
- Enable two-factor authentication on all accounts

---

Remember to customize the configuration based on your specific needs, especially:
- Firebase project IDs
- Bundle identifiers
- Email addresses
- Publishing tracks and groups
- Build triggers and conditions
