Pod::Spec.new do |s|
  s.name         = "DMTestSettings"
  s.version      = "0.1.0"
  s.summary      = "Easy accessible in-app settings for testing."
  s.description  = <<-DESC
                   Easy accessible in-app settings for testing. Shake to show settings-panel.
                   DESC
  s.homepage     = "https://github.com/duemunk/DMTestSettings"
  s.screenshots  = "https://raw.github.com/duemunk/DMTestSettings/master/Screenshots/SettingsPanel.png"
  s.license      = 'GPL3'
  s.author       = { "Tobias Due Munk" => "tobias@developmunk.dk" }
  s.source       = { :git => "https://github.com/duemunk/DMTestSettings.git", :tag => s.version.to_s }

  s.platform     = :ios, "7.0"
  s.ios.deployment_target = '7.0'
	#s.ios.framework = 'CoreGraphics', 'UIKit'
  s.requires_arc = true
 
  s.resources = 'Assets'

	s.public_header_files = 'Classes/*.h'
  s.source_files = 'Classes/*.{h,m}', 'Classes/Default Plugins/*.{h,m}'
end
