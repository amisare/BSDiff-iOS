#
# Be sure to run `pod lib lint BSDiff.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BSDiff'
  s.version          = ENV['BUMP_VERSION'] || '0.0.1'
  s.summary          = 'bsdiff and bspatch are libraries for ios'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
bsdiff and bspatch are libraries for ios.
                       DESC

  s.homepage         = 'https://github.com/amisare/BSDiff-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'amisare' => '243297288@qq.com' }
  s.source           = { :git => 'https://github.com/amisare/BSDiff-iOS.git', :tag => s.version.to_s }
  s.social_media_url = "https://www.jianshu.com/u/9df9f28ff266"

  s.requires_arc  = true
  s.libraries     = 'bz2.1.0'
  
  s.osx.deployment_target       = '10.7'
  s.ios.deployment_target       = '12.0'
  
  s.osx.pod_target_xcconfig     = { 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.nn.BSDiff' }
  s.ios.pod_target_xcconfig     = { 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.nn.BSDiff' }
  
  s.source_files = 'BSDiff/*.{m,h}','BSDiff/**/*.{c,h}'
  s.private_header_files  = 'BSDiff/bsmacros.h'
  
end
