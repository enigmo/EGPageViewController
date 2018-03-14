Pod::Spec.new do |s|
  s.name             = 'EGPageViewController'
  s.version          = '0.1.0'
  s.summary          = 'UIPageViewcontroller with built in synchronized tabs.'
 
  s.description      = <<-DESC
UIPageViewcontroller with built in synchronized tabs.
                       DESC
 
  s.homepage         = 'http://www.enigmo.co.jp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'monolithic-adam' => 'adamjhen@gmail.com' }
  s.source           = { :git => 'https://github.com/enigmo/EGPageViewController.git', :tag => s.version.to_s }
 
  s.dependency 'SnapKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.ios.deployment_target = '8.0'
  s.source_files = 'EGPageViewController/*'
 
end