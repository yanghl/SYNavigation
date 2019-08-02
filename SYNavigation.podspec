
Pod::Spec.new do |s|
s.name             = 'SYNavigation'
s.version          = '1.0.0'
s.summary          = '一个轻量级的新闻导航容器'

s.description      = <<-DESC

1、快速集成:只需一行代码即可完成框架引用
2、支持自定义导航样式:提供了大量属性供你快速设置导航栏样式
3、轻量级:没有一行多余的代码，不集成任何不需要的小功能，如果你只需要一个简单的新闻导航 那么他非常适合你
4、纯Swift:

DESC

s.homepage         = 'https://github.com/yanghl/SYNavigation'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'sean.yang' => '272789124@qq.com' }
s.source           = { :git => 'https://github.com/yanghl/SYNavigation.git', :tag => s.version.to_s }
s.ios.deployment_target = '9.0'
s.source_files = 'SYNavigation/Classes/**/*.{swift}'
s.requires_arc = true

end
