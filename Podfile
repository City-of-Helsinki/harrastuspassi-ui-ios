source 'https://github.com/CocoaPods/Specs.git'
target 'Harrastuspassi' do
  pod 'GoogleMaps'
  pod 'Google-Maps-iOS-Utils'
  pod 'GooglePlaces'
  pod 'Hero'
  pod 'RevealingSplashView'
  pod 'RangeSeekSlider'
  pod 'Kingfisher', '~> 5.0'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'MTSlideToOpen'
  pod 'Alamofire', '~> 5.0.0-rc.3'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
