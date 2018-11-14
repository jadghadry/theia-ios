source 'https://bitbucket.org/jadghadry/jgframework.git'
source 'https://github.com/CocoaPods/specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'theia-ios' do

  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for theia-ios
  pod 'Firebase/Core'
  pod 'Firebase/MLVision'
  pod 'Firebase/MLVisionTextModel'
  pod 'Firebase/MLVisionLabelModel'
  pod 'JGFramework'
  pod 'lottie-ios'

end

# Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
