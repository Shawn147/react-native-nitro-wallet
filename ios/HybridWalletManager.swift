import Foundation
import NitroModules
import PassKit
import UIKit

class HybridWalletManager: HybridWalletManagerSpec {
  func hasPass(passTypeIdentifier: String) throws -> Promise<Bool> {
    let trimmed = try requireIdentifier(passTypeIdentifier)
    let exists = PKPassLibrary().passes().contains { $0.passTypeIdentifier == trimmed }
    return Promise.resolved(withResult: exists)
  }

  func viewInWallet(passTypeIdentifier: String) throws -> Promise<Void> {
    _ = try requireIdentifier(passTypeIdentifier)

    let promise = Promise<Void>()
    DispatchQueue.main.async {
      let schemes = ["wallet://", "shoebox://", "passbook://"]
      for scheme in schemes {
        guard let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) else {
          continue
        }

        UIApplication.shared.open(url, options: [:]) { success in
          if success {
            promise.resolve()
          } else {
            promise.reject(withError: walletError("Could not open Wallet"))
          }
        }
        return
      }

      if let url = URL(string: "wallet://") {
        UIApplication.shared.open(url, options: [:]) { success in
          if success {
            promise.resolve()
          } else {
            promise.reject(withError: walletError("Could not open Wallet"))
          }
        }
        return
      }

      promise.reject(withError: walletError("Wallet URL not available"))
    }
    return promise
  }

  func canAddPasses() throws -> Promise<Bool> {
    return Promise.resolved(withResult: false)
  }

  func addPassToGoogleWallet(jwt: String) throws -> Promise<Void> {
    return Promise.rejected(withError: walletError("Google Wallet save is only supported on Android"))
  }

  func clearSavedPass(passTypeIdentifier: String) throws -> Promise<Void> {
    return Promise.resolved()
  }

  private func requireIdentifier(_ passTypeIdentifier: String) throws -> String {
    let trimmed = passTypeIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      throw walletError("passTypeIdentifier is required")
    }
    return trimmed
  }
}
