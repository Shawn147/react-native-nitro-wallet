package com.margelo.nitro.wallet

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.NitroModules
import com.margelo.nitro.core.Promise
import com.margelo.nitro.core.resolve

@DoNotStrip
@Keep
class HybridWalletManager : HybridWalletManagerSpec() {
  override fun hasPass(passTypeIdentifier: String): Promise<Boolean> =
    runCatching {
      val trimmed = requireIdentifier(passTypeIdentifier)
      walletPrefs().getBoolean(prefsKey(trimmed), false)
    }.toPromise()

  override fun viewInWallet(passTypeIdentifier: String): Promise<Unit> =
    runCatching {
      requireIdentifier(passTypeIdentifier)
      openGoogleWalletApp()
    }.toPromise()

  override fun canAddPasses(): Promise<Boolean> =
    runCatching {
      val context = requireContext()
      val pm = context.packageManager
      try {
        pm.getPackageInfo(GOOGLE_WALLET_PACKAGE, 0)
        pm.getLaunchIntentForPackage(GOOGLE_WALLET_PACKAGE) != null
      } catch (_: PackageManager.NameNotFoundException) {
        false
      }
    }.toPromise()

  override fun addPassToGoogleWallet(jwt: String): Promise<Unit> =
    runCatching {
      val trimmed = jwt.trim()
      require(trimmed.isNotEmpty()) { "JWT is empty" }

      val uri = Uri.parse("https://pay.google.com/gp/v/save/$trimmed")
      openPayGoogleUri(uri) {
        walletPrefs()
          .edit()
          .putBoolean(prefsKey(LOYALTY_PASS_TYPE_IDENTIFIER), true)
          .apply()
      }
    }.toPromise()

  override fun clearSavedPass(passTypeIdentifier: String): Promise<Unit> =
    runCatching {
      val trimmed = requireIdentifier(passTypeIdentifier)
      walletPrefs().edit().remove(prefsKey(trimmed)).apply()
    }.toPromise()

  private fun requireIdentifier(passTypeIdentifier: String): String {
    val trimmed = passTypeIdentifier.trim()
    require(trimmed.isNotEmpty()) { "passTypeIdentifier is required" }
    return trimmed
  }

  private fun openPayGoogleUri(uri: Uri, afterStart: () -> Unit = {}) {
    val context = requireContext()
    val walletOnly =
      Intent(Intent.ACTION_VIEW, uri).apply {
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        setPackage(GOOGLE_WALLET_PACKAGE)
      }

    try {
      context.startActivity(walletOnly)
      afterStart()
      return
    } catch (_: ActivityNotFoundException) {
      // Fall back to the browser/save URL if Google Wallet is not installed or hidden.
    }

    val fallback =
      Intent(Intent.ACTION_VIEW, uri).apply {
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      }

    try {
      context.startActivity(fallback)
      afterStart()
    } catch (e: ActivityNotFoundException) {
      throw IllegalStateException("Could not open Google Wallet", e)
    }
  }

  private fun openGoogleWalletApp() {
    val context = requireContext()
    val launchIntent =
      context.packageManager.getLaunchIntentForPackage(GOOGLE_WALLET_PACKAGE)
        ?: throw IllegalStateException("Google Wallet is not installed")

    try {
      launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      context.startActivity(launchIntent)
    } catch (e: ActivityNotFoundException) {
      throw IllegalStateException("Could not open Google Wallet", e)
    }
  }

  private fun walletPrefs() =
    requireContext().getSharedPreferences(WALLET_PREFS_NAME, Context.MODE_PRIVATE)

  private fun requireContext() =
    NitroModules.applicationContext
      ?: throw IllegalStateException("React application context is not available")

  private fun prefsKey(passTypeIdentifier: String): String =
    "saved_pass_" + passTypeIdentifier.replace(Regex("[^a-zA-Z0-9._-]"), "_")

  private fun <T> Result<T>.toPromise(): Promise<T> =
    fold(
      onSuccess = { Promise.resolved(it) },
      onFailure = { Promise.rejected(it) },
    )

  private companion object {
    const val GOOGLE_WALLET_PACKAGE = "com.google.android.apps.walletnfcrel"
    const val WALLET_PREFS_NAME = "danube_wallet_pass_state"
    const val LOYALTY_PASS_TYPE_IDENTIFIER = "pass.com.danube.wallet"
  }
}
