import { NitroModules } from 'react-native-nitro-modules';
let walletManager;
let walletPassKit;
export function getWalletManager() {
    if (walletManager == null) {
        walletManager =
            NitroModules.createHybridObject('WalletManager');
    }
    return walletManager;
}
export function getWalletPassKit() {
    if (walletPassKit == null) {
        walletPassKit =
            NitroModules.createHybridObject('WalletPassKit');
    }
    return walletPassKit;
}
export const WalletManager = getWalletManager();
export const WalletPassKit = getWalletPassKit();
