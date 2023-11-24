platform :ios, '12.0'

target 'MeetInfomaniak' do
  use_frameworks!
  pod 'MaterialComponents/TextFields', '123.0.0'
  pod 'JitsiMeetSDKLite', '8.6.0-lite'
end

post_install do |installer| 
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config| 
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end 
end