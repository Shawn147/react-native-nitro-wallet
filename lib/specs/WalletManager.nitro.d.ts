import type { HybridObject } from 'react-native-nitro-modules';
export interface WalletManager extends HybridObject<{
    ios: 'swift';
    android: 'kotlin';
}> {
    hasPass(passTypeIdentifier: string): Promise<boolean>;
    viewInWallet(passTypeIdentifier: string): Promise<void>;
    canAddPasses(): Promise<boolean>;
    addPassToGoogleWallet(jwt: string): Promise<void>;
    clearSavedPass(passTypeIdentifier: string): Promise<void>;
}
