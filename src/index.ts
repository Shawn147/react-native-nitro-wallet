import { NitroModules } from 'react-native-nitro-modules';

import type { WalletManager as WalletManagerModule } from './specs/WalletManager.nitro';
import type { WalletPassKit as WalletPassKitModule } from './specs/WalletPassKit.nitro';

let walletManager: WalletManagerModule | undefined;
let walletPassKit: WalletPassKitModule | undefined;

export function getWalletManager(): WalletManagerModule {
  if (walletManager == null) {
    walletManager =
      NitroModules.createHybridObject<WalletManagerModule>('WalletManager');
  }
  return walletManager;
}

export function getWalletPassKit(): WalletPassKitModule {
  if (walletPassKit == null) {
    walletPassKit =
      NitroModules.createHybridObject<WalletPassKitModule>('WalletPassKit');
  }
  return walletPassKit;
}

export const WalletManager = getWalletManager();
export const WalletPassKit = getWalletPassKit();

export type { WalletManagerModule, WalletPassKitModule };
