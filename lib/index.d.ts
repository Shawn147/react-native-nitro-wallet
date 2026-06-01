import type { WalletManager as WalletManagerModule } from './specs/WalletManager.nitro';
import type { WalletPassKit as WalletPassKitModule } from './specs/WalletPassKit.nitro';
export declare function getWalletManager(): WalletManagerModule;
export declare function getWalletPassKit(): WalletPassKitModule;
export declare const WalletManager: WalletManagerModule;
export declare const WalletPassKit: WalletPassKitModule;
export type { WalletManagerModule, WalletPassKitModule };
