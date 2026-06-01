require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "NitroWallet"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = "https://github.com/danube"
  s.license      = package["license"]
  s.authors      = package["author"]
  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/danube/react-native-nitro-wallet.git", :tag => "#{s.version}" }

  s.source_files = [
    "ios/**/*.{m,mm,swift}",
  ]

  s.compiler_flags = "-x objective-c++"

  s.pod_target_xcconfig = {
    "HEADER_SEARCH_PATHS" => ["${PODS_ROOT}/RCT-Folly"],
    "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) FOLLY_NO_CONFIG FOLLY_CFG_NO_COROUTINES",
    "OTHER_CPLUSPLUSFLAGS" => "$(inherited) -DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
  }

  load "nitrogen/generated/ios/NitroWallet+autolinking.rb"
  add_nitrogen_files(s)

  s.dependency "React-jsi"
  s.dependency "React-callinvoker"
  install_modules_dependencies(s)
end
