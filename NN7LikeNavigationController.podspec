Pod::Spec.new do |s|
  s.name         = "NN7LikeNavigationController"
  s.version      = "0.0.5"
  s.summary      = "Offer FlatUI(iOS7Like) NavigationController later iOS6."
  s.homepage     = "http://EXAMPLE/NN7LikeNavigationController"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Naoto Horiguchi" => "naoto.horiguchi@gmail.com" }
  s.platform     = :ios, '5.0'
  s.source       = { :git => "ssh://git@bitbucket.org/naonya3/nn7likenavigationcontroller.git", :tag => "0.0.6" }
  s.source_files  = 'NN7LikeNavigationController', 'NN7LikeNavigationController/*.{h,m}'
  s.framework  = 'QuartzCore'
  s.requires_arc = true
end
