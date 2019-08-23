#
# Be sure to run `pod lib lint Simplify-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Simplify-Swift'
  s.version          = '1.2.0'
  s.summary          = 'A high performance Swift 2D/3D polyline simplification library'

  s.description      = <<-DESC
Simplify-Swift is a high-performance Swift polyline simplification library ported from Simplify.js. The original Javascript library was extracted from Leaflet, a JS interactive maps library by Vladimir Agafonkin. It uses a combination of Douglas-Peucker and Radial Distance algorithms. Polyline simplification dramatically reduces the number of points in a polyline while retaining its shape, giving a huge performance boost when processing it and also reducing visual noise.
                       DESC

  s.homepage         = 'https://github.com/tomislav/Simplify-Swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tomislav Filipcic' => 'tf@7sols.com' }
  s.source           = { :git => 'https://github.com/tomislav/Simplify-Swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tomislav'
  
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/**/*'
  s.swift_version = '5.0'
end
