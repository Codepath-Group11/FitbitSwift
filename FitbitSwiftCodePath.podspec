#
# Be sure to run `pod lib lint FitbitSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FitbitSwiftCodePath'
  s.version          = '0.1.1'
  s.summary          = 'Fitbit API wrapper written in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/albertjo/FitbitSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NareshY' => 'naresh.yerneni@gmail.com' }
  s.source           = { :git => 'https://github.com/Codepath-Group11/FitbitSwift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'FitbitSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FitbitSwift' => ['FitbitSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  #
  s.requires_arc = true
  s.dependency 'SwiftyJSON'
  s.dependency 'Alamofire', '~> 4.4.0'
  s.dependency 'Locksmith'
end
