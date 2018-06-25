platform :ios, '8.0'

target 'KeyedMapperTests' do
    use_frameworks!
    inherit! :search_paths

    pod 'Quick', '1.3.0'
    pod 'Nimble', '7.1.2'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.1'
        end
    end
end
