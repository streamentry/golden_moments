# Golden Moments - Codemagic CI/CD Setup

## 🎯 Quick Start

I've set up a complete Codemagic CI/CD pipeline for your Golden Moments Flutter project. Here's what's been created:

### 📁 Configuration Files
- **`codemagic.yaml`** - Main CI/CD pipeline configuration
- **`docs/codemagic-setup.md`** - Comprehensive setup guide
- **`docs/codemagic-pipeline.md`** - Pipeline architecture documentation  
- **`docs/troubleshooting.md`** - Common issues and solutions
- **`scripts/setup-codemagic.sh`** - Setup validation script

## 🚀 Getting Started

### 1. Run Setup Validation (Optional but Recommended)
```bash
# Make the script executable (macOS/Linux)
chmod +x scripts/setup-codemagic.sh

# Run the validation script
./scripts/setup-codemagic.sh
```

### 2. Sign Up for Codemagic
1. Visit [codemagic.io](https://codemagic.io)
2. Sign up using your GitHub/GitLab/Bitbucket account
3. Connect your `golden_moments` repository

### 3. Essential Configuration Steps

#### Upload Android Keystore
1. Go to your app settings → "Code signing identities"
2. Upload your `keystore.jks` file
3. Provide keystore details (password, alias, key password)

#### Configure Environment Variables
Add these in Codemagic dashboard:
```
FIREBASE_TOKEN=your_firebase_token
GCLOUD_SERVICE_ACCOUNT_CREDENTIALS=your_service_account_json
APP_STORE_CONNECT_ISSUER_ID=your_issuer_id
APP_STORE_CONNECT_KEY_IDENTIFIER=your_key_id  
APP_STORE_CONNECT_PRIVATE_KEY=your_private_key
```

#### Set Up iOS Signing
1. Choose "Automatic" for easier setup
2. Codemagic will manage provisioning profiles
3. Bundle ID: `com.mindfulness.golden_moments`

## 🔄 Workflow Overview

The pipeline includes three workflows:

### Development Workflow
- **Triggers**: Feature branches
- **Builds**: Development flavor APK/iOS
- **Distribution**: Firebase App Distribution

### Production Workflow  
- **Triggers**: main/master branch
- **Builds**: Production flavor APK/AAB/iOS
- **Distribution**: Google Play (internal) + TestFlight

### Pull Request Workflow
- **Triggers**: Pull requests
- **Purpose**: Code quality checks
- **Output**: Analysis and test reports

## 🎯 Build Flavors Support

Your existing flavors are fully configured:
- **development**: `[DEV] Golden Moments`
- **staging**: `[STG] Golden Moments` 
- **production**: `Golden Moments`

## 📱 Key Features

✅ **Multi-platform builds** (Android APK/AAB + iOS IPA)  
✅ **Automated testing** (analyze, test, format check)  
✅ **Code signing** (environment variable based)  
✅ **Store publishing** (Google Play + App Store)  
✅ **Firebase distribution** (for testing)  
✅ **Email notifications** (success/failure alerts)  
✅ **Artifact management** (downloadable builds)  

## 🔧 Customization

The configuration is ready to use but you may want to customize:

1. **Firebase App IDs**: Update in `codemagic.yaml` lines 61-69
2. **Email addresses**: Update notification recipients  
3. **Publishing tracks**: Change Google Play/TestFlight settings
4. **Build triggers**: Modify branch patterns as needed

## 📚 Documentation

For detailed information, see:
- **Setup Guide**: `docs/codemagic-setup.md`
- **Pipeline Docs**: `docs/codemagic-pipeline.md`
- **Troubleshooting**: `docs/troubleshooting.md`

## 🆘 Next Steps

1. **Test locally** - Ensure builds work on your machine
2. **Set up Codemagic account** - Connect repository and configure
3. **First build** - Push a commit to trigger your first build
4. **Monitor and optimize** - Review build times and success rates

## 💡 Pro Tips

- Start with the development workflow to test your setup
- Use Firebase App Distribution for easy beta testing
- Monitor build logs for optimization opportunities
- Set up proper notification preferences for your team

---

Your Golden Moments project is now ready for professional CI/CD with Codemagic! 🎉

For any issues, check the troubleshooting guide or reach out to Codemagic support.
