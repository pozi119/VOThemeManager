Pod::Spec.new do |s|
  s.name         = "VOThemeManager"
  s.version      = "1.0.1"
  s.summary      = "A Theme Manager."
  s.description  = <<-DESC
                   ** A Theme Manager **
                   DESC

  s.homepage     = "https://github.com/pozi119/VOThemeManager"
  s.license      = "GPL V3.0"
  s.author       = { "pozi119" => "pozi119@163.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/pozi119/VOThemeManager.git", :tag => s.version.to_s }
  s.source_files = "VOThemeManager/*.{h,m}"
  s.dependency     "YYCache"
end
