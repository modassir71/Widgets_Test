# Uncomment the next line to define a global platform for your project
 platform :ios, '14.0'

target 'IntentsExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for IntentsExtension

end

target 'IntentsExtensionUI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for IntentsExtensionUI

end

target 'MultiWidgetExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MultiWidgetExtension

end

target 'Widgets' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'DTPagerController'
  pod 'NVActivityIndicatorView', '~> 4.4.0'
  pod 'Loaf'

  # Permissions
  pod 'Permission/Notifications', :git => 'https://github.com/eb-miguelhernandez/Permission'

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
            end
        end
    end
end

end
