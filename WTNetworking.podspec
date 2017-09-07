#
# Be sure to run `pod lib lint WTNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WTNetworking'
  s.version          = '1.0.0'
  s.summary          = 'WTNetworking is network feature set'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
WTNetworking is network feature set.
                       DESC

  s.homepage         = 'https://github.com/hongruqi/WTNetworking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lbrsilva-allin' => 'hongru.qi@quvideo.com' }
  s.source           = { :git => 'https://github.com/hongruqi/WTNetworking.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WTNetworking/Classes/**/*'
  
  s.dependency 'AFNetworking'
  s.dependency 'YYModel'
end

