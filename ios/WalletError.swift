import NitroModules

func walletError(_ message: String) -> Error {
  return RuntimeError.error(withMessage: message)
}
