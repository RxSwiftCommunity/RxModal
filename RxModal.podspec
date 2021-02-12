Pod::Spec.new do |s|
  s.name         = "RxModal"
  s.version      = "1.0.0"
  s.summary      = "Subscribe to your modal flows"
  s.description  = <<-DESC
    RxModal helps you handle any modal flow as a simple Observable sequence.
  DESC
  s.homepage     = "https://github.com/RxSwiftCommunity/RxModal"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jérôme Alves" => "j.alves@me.com" }
  s.social_media_url   = "https://twitter.com/jegnux"
  s.ios.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/RxSwiftCommunity/RxModal.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  
  s.dependency 'RxSwift', '~> 6.1'
  s.dependency 'RxCocoa', '~> 6.1'

end
