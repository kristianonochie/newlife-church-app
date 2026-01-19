## Android Release Guide (NewLife)

Follow these steps to generate a release keystore, wire signing into the Android build, create an AAB, and upload to Google Play.

1) Generate a keystore (Windows PowerShell example)

   - Run locally (fills `my-release-key.jks`):

   ```powershell
   # Update the alias and passwords as needed
   keytool -genkeypair -v -keystore %USERPROFILE%\\.android\\my-release-key.jks -alias newlife_key -keyalg RSA -keysize 2048 -validity 10000
   ```

2) Create a `keystore.properties` file (do NOT commit secrets). Example path: `android/keystore.properties`:

   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=newlife_key
   storeFile=C:\\Users\\YourUser\\.android\\my-release-key.jks
   ```

3) Add signing config to `android/app/build.gradle` (snippet) — place inside `android { ... }`:

   ```groovy
   def keystorePropertiesFile = rootProject.file('keystore.properties')
   def keystoreProperties = new Properties()
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       // ... existing config
       signingConfigs {
           release {
               if (keystorePropertiesFile.exists()) {
                   storeFile file(keystoreProperties['storeFile'])
                   storePassword keystoreProperties['storePassword']
                   keyAlias keystoreProperties['keyAlias']
                   keyPassword keystoreProperties['keyPassword']
               }
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
               // minifyEnabled true // if using proguard
           }
       }
   }
   ```

4) Build the Android App Bundle (AAB):

   ```powershell
   flutter pub get
   flutter build appbundle --release
   ```

   Output: `build/app/outputs/bundle/release/app-release.aab` — upload this file to Play Console.

5) Play Console checklist:
   - Create an app in Play Console (set package id same as `android/app/src/main/AndroidManifest.xml`).
   - Upload AAB to internal testing first, verify on test devices.
   - Provide store listing, screenshots, privacy policy, content rating, and target audience info.
   - Set up pricing and distribution, then roll out to production when ready.

Security notes:
 - Never commit keystore passwords or `keystore.properties` with real secrets.
 - Back up your keystore file securely; losing it prevents updates to published apps.

If you want, I can:
- create a `scripts/generate_keystore.ps1` to run the `keytool` command for you (PowerShell),
- add the `keystore.properties.template` file into the repo (placeholder values),
- or insert the `build.gradle` snippet into `android/app/build.gradle` for you (requires careful verification).
