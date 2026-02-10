# How to Release a Signed and Notarized Version of FastPlayer

This guide covers the complete process of building, signing, notarizing, and releasing a new version of FastPlayer for macOS distribution.

## Prerequisites

- Xcode 14.0 or later
- Apple Developer Program membership
- Developer ID Application certificate installed
- App-specific password for notarization
- GitHub CLI (`gh`) installed and authenticated
- macOS 12.0 or later

## Step 1: Prepare the Project

Ensure your project is clean and ready for release:

```bash
cd /path/to/FastPlayer/FastPlayer
git status  # Check for any uncommitted changes
git pull    # Ensure you have the latest changes
```

## Step 2: Configure Export Options

Update `exportOptions.plist` with the correct Developer ID certificate information:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>V6373HMDL9</string>
    <key>signingCertificate</key>
    <string>Developer ID Application: Miroslav Zahorak (V6373HMDL9)</string>
    <key>signingStyle</key>
    <string>manual</string>
</dict>
</plist>
```

## Step 3: Build the App Archive

Create an archive of the app using Xcode:

```bash
xcodebuild -scheme FastPlayer -configuration Release -archivePath ./build/FastPlayer.xcarchive archive
```

## Step 4: Export with Developer ID Signing

Export the archived app with Developer ID signing:

```bash
xcodebuild -exportArchive -archivePath ./build/FastPlayer.xcarchive -exportOptionsPlist exportOptions.plist -exportPath ./build/exported
```

**Note**: If this fails with certificate errors, proceed to manual signing (Step 5).

## Step 5: Manual Signing (if export fails)

If the automated export fails, manually sign the app:

```bash
# Copy the app from archive
mkdir -p build/exported
cp -r build/FastPlayer.xcarchive/Products/Applications/FastPlayer.app build/exported/

# Sign with Developer ID certificate and hardened runtime
codesign --deep --force --verbose --options=runtime --sign "Developer ID Application: Miroslav Zahorak (V6373HMDL9)" build/exported/FastPlayer.app
```

## Step 6: Verify Signature

Check that the app is properly signed:

```bash
codesign --verify --deep --strict --verbose=2 build/exported/FastPlayer.app
```

Expected output should show: `build/exported/FastPlayer.app: valid on disk`

## Step 7: Prepare for Notarization

Create a zip file for notarization submission:

```bash
cd build/exported
ditto -c -k --keepParent FastPlayer.app FastPlayer.zip
```

## Step 8: Submit for Notarization

Submit the app to Apple for notarization:

```bash
xcrun notarytool submit FastPlayer.zip --apple-id your-apple-id@email.com --password your-app-specific-password --team-id V6373HMDL9 --wait
```

**Note**: Replace with your actual Apple ID and app-specific password.

## Step 9: Check Notarization Status

If you didn't use `--wait`, check the status manually:

```bash
xcrun notarytool info SUBMISSION-ID --apple-id your-apple-id@email.com --password your-app-specific-password --team-id V6373HMDL9
```

## Step 10: Staple Notarization Ticket

Once notarization is approved, attach the ticket to the app:

```bash
xcrun stapler staple FastPlayer.app
```

## Step 11: Verify Gatekeeper Acceptance

Test that the app passes Gatekeeper checks:

```bash
spctl --assess --verbose FastPlayer.app
```

Expected output: `FastPlayer.app: accepted` with `source=Notarized Developer ID`

## Step 12: Create Distribution Package

Create the final distribution zip:

```bash
ditto -c -k --keepParent FastPlayer.app FastPlayer-X.Y.Z.zip
```

Replace `X.Y.Z` with your version number (e.g., `FastPlayer-1.0.0.zip`).

## Step 13: Create GitHub Release

Create a new release on GitHub:

```bash
cd /path/to/FastPlayer/FastPlayer
gh release create vX.Y.Z build/exported/FastPlayer-X.Y.Z.zip --title "FastPlayer vX.Y.Z" --notes "Release notes describing the new version features and improvements."
```

## Step 14: Update README.md

Update the README with the new release information:

1. Update the download section with the new version
2. Update the download link
3. Remove or update installation instructions if needed
4. Add any new features or changes

## Step 15: Verify Release

Check that the release was created successfully:

```bash
gh release list
gh release view vX.Y.Z
```

## Troubleshooting

### Certificate Issues
- Verify your Developer ID Application certificate is installed: `security find-identity -v -p codesigning`
- Check that the certificate name matches exactly in exportOptions.plist

### Notarization Failures
- Check notarization logs: `xcrun notarytool log SUBMISSION-ID --apple-id ... --password ... --team-id ...`
- Common issues: Missing hardened runtime, incorrect signing

### Gatekeeper Rejections
- Ensure the app is notarized and the ticket is stapled
- Verify the signature is valid
- Check that you're using the Developer ID Application certificate (not Development)

## Version Numbering

Use semantic versioning (X.Y.Z):
- **Major (X)**: Breaking changes
- **Minor (Y)**: New features, backward compatible
- **Patch (Z)**: Bug fixes, backward compatible

## Files to Update

After each release, update these files:
- `README.md`: Download links and installation instructions
- Version numbers in any configuration files
- Release notes in GitHub

## Security Best Practices

- Always use Developer ID Application certificates for distribution
- Enable hardened runtime for maximum security
- Submit all apps for notarization
- Keep certificates and app-specific passwords secure
- Regularly update to the latest Xcode and macOS versions

## Example Commands for v1.0.0 Release

```bash
# Build and archive
xcodebuild -scheme FastPlayer -configuration Release -archivePath ./build/FastPlayer.xcarchive archive

# Manual signing with hardened runtime
codesign --deep --force --verbose --options=runtime --sign "Developer ID Application: Miroslav Zahorak (V6373HMDL9)" build/exported/FastPlayer.app

# Notarization
xcrun notarytool submit FastPlayer.zip --apple-id miro@misia.sk --password fmhw-fwyn-hdlo-zyxf --team-id V6373HMDL9 --wait

# Staple and verify
xcrun stapler staple FastPlayer.app
spctl --assess --verbose FastPlayer.app

# Create release
gh release create v1.0.0 build/exported/FastPlayer-1.0.0.zip --title "FastPlayer v1.0.0" --notes "First stable release with proper code signing and notarization."
```