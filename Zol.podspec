#
# Be sure to run `pod lib lint Zol.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Zol'
  s.version          = '0.0.3'
  s.summary          = 'Zol is a dependency injection framework written for Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Zol is a dependency injection framework written for Swift. Inspired by Kotlin Koin. 
  This framework is meant to be lightweight and unopinionated by design with resolutions working 
  simply by good old functional programming.
                       DESC

  s.homepage         = 'https://github.com/drewkiino/Zol'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'drewkiino' => 'andrewaquino118@gmail.com' }
  s.source           = { :git => 'https://github.com/drewkiino/Zol.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Zol/Classes/**/*'
  s.swift_version = '5.0'

  # s.resource_bundles = {
  #   'Viper' => ['Viper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
