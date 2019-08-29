use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'
target 'Harrastuspassi' do
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Hero'
  pod 'RevealingSplashView'
  pod 'RangeSeekSlider'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
