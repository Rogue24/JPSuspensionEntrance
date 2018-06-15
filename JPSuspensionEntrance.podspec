#
# Be sure to run `pod lib lint JPSuspensionEntrance.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JPSuspensionEntrance'
  s.version          = '0.1.0'
  s.summary          = '高仿微信悬浮窗口的小框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
高仿微信悬浮窗口的一个小框架，简单易用，可支持有导航栏的情况
                       DESC

  s.homepage         = 'https://github.com/Rogue24/JPSuspensionEntrance'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZhouJianPing' => 'zhoujianping24@hotmail.com' }
  s.source           = { :git => 'https://github.com/Rogue24/JPSuspensionEntrance.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'JPSuspensionEntrance/Classes/**/*'
  
  s.resource_bundles = {
    'JPSuspensionEntrance' => ['JPSuspensionEntrance/Assets/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
