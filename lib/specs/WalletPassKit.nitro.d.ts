import type { HybridObject } from 'react-native-nitro-modules';
export interface WalletPassKit extends HybridObject<{
    ios: 'swift';
    android: 'kotlin';
}> {
    canAddPasses(): Promise<boolean>;
    addPass(base64PkPass: string): Promise<void>;
}
