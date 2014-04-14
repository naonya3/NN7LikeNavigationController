Pod::Spec.new do |s|
  s.name         = "NN7LikeNavigationController"
  s.version      = "0.1.7"
  s.summary      = "Offer FlatUI(iOS7Like) NavigationController later iOS6."
  s.homepage     = "http://EXAMPLE/NN7LikeNavigationController"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Naoto Horiguchi" => "naoto.horiguchi@gmail.com" }
  s.platform     = :ios, '5.0'
  s.source       = { :git => "git@github.com:naonya3/NN7LikeNavigationController.git", :tag => "0.1.7" }
  s.source_files  = 'NN7LikeNavigationController', 'NN7LikeNavigationController/*.{h,m}'
  s.framework  = 'QuartzCore'
  s.requires_arc = true
end
