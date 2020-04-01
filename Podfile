platform :ios, '11.0'

workspace 'MeetInfomaniak.xcworkspace'

target 'MeetInfomaniak' do
  project 'MeetInfomaniak.xcodeproj'

  pod 'JitsiMeetSDK'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end