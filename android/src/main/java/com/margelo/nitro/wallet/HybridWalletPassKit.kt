package com.margelo.nitro.wallet

import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.core.Promise

@DoNotStrip
@Keep
class HybridWalletPassKit : HybridWalletPassKitSpec() {
  override fun canAddPasses(): Promise<Boolean> = Promise.resolved(false)

  override fun addPass(base64PkPass: String): Promise<Unit> =
    Promise.rejected(UnsupportedOperationException("Apple Wallet passes are only supported on iOS"))
}
