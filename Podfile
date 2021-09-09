source 'https://github.com/CocoaPods/Specs.git'

platform:ios,'13.0'
install! 'cocoapods', generate_multiple_pod_projects: true
use_frameworks!
#ignore all warnings from all pods
inhibit_all_warnings!

def pods
  inherit! :search_paths
#Swift

## RxSwift
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxDataSources'
    pod 'Action'
    pod 'NSObject+Rx'
    pod 'RxKingfisher'
    pod 'Moya/RxSwift'
    pod 'RxKeyboard'
    pod 'RxBinding'
    pod 'RxWebKit'
#    pod 'RxFSPagerView'
## Other
    #pod 'KeychainAccess'
    pod 'SnapKit'
    #pod 'Hero'
    pod 'R.swift'
    pod 'IQKeyboardManagerSwift'
    #pod 'FSPagerView'
    #pod 'MarqueeLabel/Swift'
    pod 'DQPopup'
    #pod 'NVActivityIndicatorView'
    #pod 'Starscream'
    #pod 'RealmSwift'
    #pod 'WalletConnectSwift', git: 'https://github.com/QiuDaniel/WalletConnectSwift', branch: 'master'
    pod 'EmptyDataSet-Swift'
    pod 'DQSegmentedControl/Rx'
## Image
    pod 'KingfisherWebP'
    
    
## Objective-C
    pod 'SSZipArchive'
    pod 'ZLCollectionViewFlowLayout', '~> 1.2.0'
    pod 'MJRefresh'
    pod 'MBProgressHUD'
    #pod 'HMSegmentedControl'
    #pod 'WechatOpenSDK'
## Push SDK
    pod 'UMCCommon'
    pod 'UMCPush'
    pod 'UMCCommonLog', :configurations => ['Debug']
    
## DEBUG
    pod 'LookinServer', :configurations => ['Debug']

end

target 'EBook' do
	pods
  
  target 'EBookTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pod_target_subprojects.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
  installer.pod_target_subprojects.flat_map { |p| p.targets }.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

