# react-native-nitro-wallet

High-performance Apple Wallet and Google Wallet helpers for React Native, built with [Nitro Modules](https://nitro.margelo.com/).

## Features

- Nitro Module native bindings for low-overhead calls from JavaScript.
- Apple Wallet pass detection, Wallet opening, and `.pkpass` add flow on iOS.
- Google Wallet JWT save flow on Android.
- Small typed TypeScript API with lazy hybrid object creation.
- Android autolinking support through `NitroWalletPackage`.
- iOS CocoaPods autolinking through generated Nitro bindings.

## Installation

```sh
npm install react-native-nitro-wallet react-native-nitro-modules
```

For iOS, install pods after adding the package:

```sh
cd ios
pod install
```

This package expects a React Native project with Nitro Modules configured.

## Usage

```ts
import { WalletManager, WalletPassKit } from 'react-native-nitro-wallet';

const canAddApplePasses = await WalletPassKit.canAddPasses();

if (canAddApplePasses) {
  await WalletPassKit.addPass(base64PkPass);
}

const hasPass = await WalletManager.hasPass('pass.com.example.wallet');

if (hasPass) {
  await WalletManager.viewInWallet('pass.com.example.wallet');
}

await WalletManager.addPassToGoogleWallet(googleWalletJwt);
```

## API

### `WalletManager.hasPass(passTypeIdentifier)`

Checks whether Apple Wallet contains a pass with the given pass type identifier.

- iOS: returns `true` when the pass exists in `PKPassLibrary`.
- Android: returns whether the identifier has been saved by the Google Wallet helper.

### `WalletManager.viewInWallet(passTypeIdentifier)`

Opens the native wallet app.

- iOS: opens Apple Wallet.
- Android: opens Google Wallet or its Play Store listing when needed.

### `WalletManager.canAddPasses()`

Checks whether the current platform can start the platform-specific wallet add flow.

### `WalletManager.addPassToGoogleWallet(jwt)`

Starts the Google Wallet save flow with a signed JWT.

- Android: opens the Google Wallet save URL.
- iOS: rejects because Google Wallet save is Android-only in this module.

### `WalletManager.clearSavedPass(passTypeIdentifier)`

Clears the locally stored Android marker for a saved Google Wallet pass.

### `WalletPassKit.canAddPasses()`

Checks whether Apple Wallet can add passes on the current iOS device.

### `WalletPassKit.addPass(base64PkPass)`

Presents the native Apple Wallet add-pass UI for a base64 encoded `.pkpass` payload.

## Platform Notes

### iOS

`WalletPassKit.addPass` accepts raw base64 or a data URL string. The native implementation decodes the payload, creates a `PKPass`, and presents `PKAddPassesViewController` on the main thread.

`WalletManager.viewInWallet` opens Wallet using system URL schemes. Make sure your app has any URL scheme visibility configuration required by your target iOS version and app policy.

### Android

`WalletManager.addPassToGoogleWallet` opens:

```txt
https://pay.google.com/gp/v/save/{jwt}
```

The module stores a local marker after starting the save flow so `hasPass` can answer quickly for the configured pass identifier. The Google Wallet app package used for detection is:

```txt
com.google.android.apps.walletnfcrel
```

## Development

```sh
npm run typecheck
npm run specs
npm run build
npm run pack:check
```

`npm run specs` regenerates Nitro bindings from the TypeScript specs.

## License

MIT
