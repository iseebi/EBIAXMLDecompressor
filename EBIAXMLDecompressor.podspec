Pod::Spec.new do |s|
  s.name         = "EBIAXMLDecompressor"
  s.version      = "0.1.0"
  s.summary      = "decompress zipaligned XML in Android APK"
  s.homepage     = "https://github.com/iseebi/EBIAXMLDecompressor"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Nobuhiro Ito" => "iseebi@iseteki.net" }
  s.social_media_url = "https://twitter.com/iseebi"
  s.platform     = :osx, "10.9"
  s.source       = { :git => "https://github.com/iseebi/EBIAXMLDecompressor.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.public_header_files = "Classes/**/*.h"
end
