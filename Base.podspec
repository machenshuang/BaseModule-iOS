#
# Be sure to run `pod lib lint Base.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Base'
  s.version          = '1.0.0'
  s.summary          = 'A short description of Base.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/chenshuangma@foxmail.com/Base'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chenshuangma@foxmail.com' => 'machenshuang@joyy.com' }
  s.source           = { :git => 'https://github.com/chenshuangma@foxmail.com/Base.git', :branch => "master" }
  s.ios.deployment_target = '12.0'

  s.source_files = 'Base/**/*.{h,m,swift'
  s.public_header_files = "Base/**/*.h"
  s.frameworks = "AudioToolbox", 'CoreVideo'
  s.static_framework = true
  
  s.dependency 'UMCommon', '~> 7.3.0' # 统计
  s.dependency 'UMDevice', '~> 2.2.0' # 统计
  s.dependency 'Bugly', '~> 2.5.0' # 崩溃
  s.dependency 'CocoaLumberjack/Swift', '~> 3.7.0' # 日志
  s.dependency 'Kingfisher', '~> 7.2.0'
  s.dependency 'HandyJSON', '~> 5.0.0'
  s.dependency 'Moya', '~> 15.0.0'
  s.dependency 'RxSwift', '~> 5.1.0'
end
