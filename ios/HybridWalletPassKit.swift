import Foundation
import NitroModules
import PassKit
import UIKit

class HybridWalletPassKit: HybridWalletPassKitSpec {
  private var pendingPromise: Promise<Void>?
  private lazy var addPassDelegate = AddPassDelegate { [weak self] controller in
    self?.finishAddingPass(controller)
  }

  func canAddPasses() throws -> Promise<Bool> {
    return Promise.resolved(withResult: PKAddPassesViewController.canAddPasses())
  }

  func addPass(base64PkPass: String) throws -> Promise<Void> {
    let promise = Promise<Void>()

    DispatchQueue.main.async {
      guard self.pendingPromise == nil else {
        promise.reject(withError: walletError("Another pass is already being added"))
        return
      }

      let trimmed = base64PkPass.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else {
        promise.reject(withError: walletError("Pass data is empty"))
        return
      }

      var payload = trimmed
      if let comma = payload.firstIndex(of: ","), payload.lowercased().hasPrefix("data:") {
        payload = String(payload[payload.index(after: comma)...])
      }
      payload = payload.replacingOccurrences(of: "\n", with: "")
      payload = payload.replacingOccurrences(of: "\r", with: "")
      payload = payload.replacingOccurrences(of: " ", with: "")

      guard let data = Data(base64Encoded: payload, options: [.ignoreUnknownCharacters]) else {
        promise.reject(withError: walletError("Could not decode pass data"))
        return
      }

      guard let pass = try? PKPass(data: data) else {
        promise.reject(withError: walletError("Could not read Wallet pass"))
        return
      }

      guard PKAddPassesViewController.canAddPasses() else {
        promise.reject(withError: walletError("This device cannot add passes"))
        return
      }

      guard let controller = PKAddPassesViewController(pass: pass) else {
        promise.reject(withError: walletError("Could not create add-pass UI"))
        return
      }

      guard let host = self.topViewController() else {
        promise.reject(withError: walletError("Could not find root view controller"))
        return
      }

      controller.delegate = self.addPassDelegate
      self.pendingPromise = promise
      host.present(controller, animated: true)
    }

    return promise
  }

  private func finishAddingPass(_ controller: PKAddPassesViewController) {
    controller.dismiss(animated: true) {
      self.pendingPromise?.resolve()
      self.pendingPromise = nil
    }
  }

  private func topViewController(
    _ root: UIViewController? = UIApplication.shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })?
      .rootViewController
  ) -> UIViewController? {
    if let nav = root as? UINavigationController {
      return topViewController(nav.visibleViewController)
    }
    if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
      return topViewController(selected)
    }
    if let presented = root?.presentedViewController {
      return topViewController(presented)
    }
    return root
  }
}

private final class AddPassDelegate: NSObject, PKAddPassesViewControllerDelegate {
  private let onFinish: (PKAddPassesViewController) -> Void

  init(onFinish: @escaping (PKAddPassesViewController) -> Void) {
    self.onFinish = onFinish
  }

  func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
    onFinish(controller)
  }
}
