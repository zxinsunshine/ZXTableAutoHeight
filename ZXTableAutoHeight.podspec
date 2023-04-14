
Pod::Spec.new do |s|
    s.name             = "ZXTableAutoHeight"
    s.version          = "1.0"
    s.summary          = "根据UITableViewCell的自动布局计算高度的框架"
    s.author           = { "Theo Though" => "zxinsunshine@126.com" }
    s.homepage         = "https://github.com/xxx"
    s.license          = 'MIT'
    s.source = {
        :git => 'https://github.com/xxx.git',
        :tag => s.version.to_s,
        :branch => 'master'
        # :http => "http://xxx.zip" # zip包资源需要配置url
    }

    s.dependency 'IGListDiffKit'
    s.source_files = 'AutoHeightManger/**/*.{h,m,mm,swift}'
    s.public_header_files = 'AutoHeightManger/*.h', 'AutoHeightManger/Protocol/*.h', 'AutoHeightManger/Categories/NSObject+ZXTableViewAutoHeightMark.h'

    s.ios.deployment_target = '13.0'
 
end
    