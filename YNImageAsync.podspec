Pod::Spec.new do |s|
  s.name         = 'YNImageAsync'
  s.version      = '1.0'
  s.summary      = 'Lightweight image loading and caching framework'
  s.homepage     = 'https://uploadcare.com'
  s.license      = 'MIT'
  s.authors      = { 'Yury Nechaev' => 'nechaev.main@gmail.com' }
  s.source       = { :git => 'https://github.com/ynechaev/YNImageAsync.git', :tag => s.version.to_s }
  s.source_files = 'YNImageAsync/**/*.{swift,h}'
  s.requires_arc = true
  s.platform     = :ios, '9.0'
end
