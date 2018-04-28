#
# Be sure to run `pod lib lint FineEpub.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FineEpub'
  s.version          = '0.1.0-beta4'
  s.summary          = 'A Simple pub reader writer in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A Simple pub reader writer in Swift and use javascript and css to show epubs.
                       DESC

  s.homepage         = 'https://github.com/mehdok/iOSFineEpub'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mehdi Sohrabi' => 'mehdok@gmail.com' }
  s.source           = { :git => 'https://github.com/mehdok/iOSFineEpub.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'FineEpub/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FineEpub' => ['FineEpub/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Fuzi', '~> 2.0.1'
  s.dependency 'objective-zip', '~> 1.0.5'
  s.dependency 'SwiftSoup'
end
