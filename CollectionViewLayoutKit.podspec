#
# Be sure to run `pod lib lint CollectionViewLayoutKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CollectionViewLayoutKit'
  s.version          = '1.0.0'
  s.summary          = 'A short description of CollectionViewLayoutKit.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/tanxl/CollectionViewLayoutKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tanxl' => '125322078@qq.com' }
  s.source           = { :git => 'https://github.com/tanxl/CollectionViewLayoutKit.git', :tag => s.version.to_s }
  
  s.static_framework = true
  
  s.ios.deployment_target = '10.0'
  
  s.source_files = 'CollectionViewLayoutKit/Classes/**/*'
  
end
