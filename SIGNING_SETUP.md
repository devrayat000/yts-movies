# 🔐 App Signing Setup Guide

This guide will help you set up proper app signing for your YTS Movies Flutter app.

## 📋 Prerequisites

- Java JDK installed (for `keytool` command)
- Access to your GitHub repository settings
- PowerShell (for Windows) or Terminal (for macOS/Linux)

## 🚀 Quick Setup (Recommended)

### Option 1: Using the Setup Script (Windows)

1. **Run the setup script:**

   ```powershell
   .\setup-signing.ps1
   ```

2. **Follow the prompts** to enter:
   - Keystore password (remember this!)
   - Key password
   - Certificate information (name, organization, etc.)

3. **Add GitHub Secrets:**
   - Go to your repository on GitHub
   - Navigate to: **Settings** → **Secrets and variables** → **Actions**
   - Add the two secrets that the script outputs:
     - `KEYSTORE_BASE64`
     - `KEY_PROPERTIES`

### Option 2: Manual Setup

#### Step 1: Generate Keystore

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

#### Step 2: Create key.properties

Create `android/key.properties` with:

```properties
storePassword=your_store_password
keyPassword=your_key_password  
keyAlias=upload
storeFile=../upload-keystore.jks
```

#### Step 3: Generate Base64 for GitHub

**Windows:**

```powershell
$keystoreBytes = [System.IO.File]::ReadAllBytes("android/upload-keystore.jks")
[System.Convert]::ToBase64String($keystoreBytes)
```

**macOS/Linux:**

```bash
base64 -i android/upload-keystore.jks
```

#### Step 4: Add GitHub Secrets

Add these secrets to your GitHub repository:

1. **KEYSTORE_BASE64**: The base64 encoded keystore file
2. **KEY_PROPERTIES**: The contents of your key.properties file

## 📱 How it Works

### Build Configuration

The app is now configured to:

- ✅ Use release signing for production builds
- ✅ Enable code minification and resource shrinking
- ✅ Use ProGuard for optimization
- ✅ Fall back to debug signing if secrets are missing

### GitHub Actions Workflow

When you create a PR to the `prod` branch, the workflow will:

1. **🔍 Check for secrets** - Looks for `KEYSTORE_BASE64` and `KEY_PROPERTIES`
2. **🔐 Setup signing** - Creates keystore and properties files if secrets exist
3. **🏗️ Build APK** - Compiles a signed release APK
4. **📦 Upload artifact** - Makes the APK downloadable
5. **💬 Comment on PR** - Shows build status and signing info

### Signing Status

The workflow will indicate in the PR comment:

- 🔐 **Signed with release keystore** - Your custom signing key was used
- ⚠️ **Signed with debug keystore** - Default debug key was used (secrets missing)

## 🔒 Security Notes

### What's Protected

- ✅ Keystore file (`.jks`) - Not committed to repository
- ✅ Key properties - Not committed to repository  
- ✅ Passwords - Stored as GitHub secrets
- ✅ Private keys - Encrypted in keystore

### Important

- 🚨 **Never commit your keystore or key.properties to the repository**
- 🚨 **Keep your keystore password safe - you can't recover it!**
- 🚨 **Back up your keystore file securely**
- 🚨 **Use the same keystore for all app updates**

## 🗂️ File Structure

```
android/
├── key.properties          # 🚫 Not in git (signing config)
├── upload-keystore.jks     # 🚫 Not in git (your keystore)
├── .gitignore             # ✅ Protects signing files
└── app/
    └── build.gradle.kts   # ✅ Signing configuration
```

## 🛠️ Troubleshooting

### Build Fails with Signing Error

- ✅ Check that GitHub secrets are properly set
- ✅ Verify key.properties format
- ✅ Ensure keystore was created correctly

### APK Shows Debug Signing

- ✅ Confirm secrets are named correctly: `KEYSTORE_BASE64` and `KEY_PROPERTIES`
- ✅ Check GitHub Actions logs for setup errors
- ✅ Verify base64 encoding is correct

### Can't Find Java keytool

- ✅ Install Java JDK (not just JRE)
- ✅ Add Java bin directory to PATH
- ✅ Restart terminal/PowerShell

## 📚 Additional Resources

- [Android App Signing Guide](https://developer.android.com/studio/publish/app-signing)
- [Flutter Deployment Guide](https://flutter.dev/docs/deployment/android)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

🎉 **Ready to build signed APKs!** Create a pull request to the `prod` branch and watch your app get built with proper signing.
