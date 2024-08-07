//
//  AnchorSettingPanel.swift
//  TUILiveKit
//
//  Created by WesleyLei on 2023/11/15.
//

import Combine
import Foundation
import RTCCommon

class AnchorSettingPanel: UIView {
    private let store: LiveStore
    private let routerStore: RouterStore
    private var cancellableSet = Set<AnyCancellable>()
    weak var rootController: UIViewController?
    init(store: LiveStore, routerStore: RouterStore) {
        self.store = store
        self.routerStore = routerStore
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isPortrait: Bool = {
        WindowUtils.isPortrait
    }()
    
    private var isViewReady: Bool = false
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        setView()
        isViewReady = true
    }
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.text = .settingTitleText
        view.textColor = .g7
        view.font = .customFont(ofSize: 16)
        view.textAlignment = .center
        return view
    }()
    
    private lazy var featureItems: [FeatureItem] = {
        var items: [FeatureItem] = []
        var designConfig = FeatureItemDesignConfig()
        designConfig.backgroundColor = .g3
        designConfig.cornerRadius = 10
        designConfig.titleFont = .customFont(ofSize: 12)
        designConfig.type = .imageAboveTitleBottom
        items.append(FeatureItem(normalTitle: .beautyText,
                                 normalImage: .liveBundleImage("live_videoSetting_beauty"),
                                 designConfig: designConfig,
                                 actionClosure: { [weak self] _ in
            guard let self = self else { return }
            self.beautyClick()
        }))
        items.append(FeatureItem(normalTitle: .audioEffectsText,
                                 normalImage: .liveBundleImage("live_setting_audio_effects"),
                                 designConfig: designConfig,
                                 actionClosure: { [weak self] _ in
            guard let self = self else { return }
            self.audioEffectClick()
        }))
        items.append(FeatureItem(normalTitle: .flipText,
                                 normalImage: .liveBundleImage("live_videoSetting_flip"),
                                 designConfig: designConfig,
                                 actionClosure: { [weak self] _ in
            guard let self = self else { return }
            self.flipClick()
        }))
        items.append(FeatureItem(normalTitle: .mirrorText,
                                 normalImage: .liveBundleImage("live_videoSetting_mirror"),
                                 designConfig: designConfig,
                                 actionClosure: { [weak self] _ in
            guard let self = self else { return }
            self.mirrorClick()
        }))
        items.append(FeatureItem(normalTitle: .videoParametersText,
                                 normalImage: .liveBundleImage("live_setting_video_parameters"),
                                 designConfig: designConfig,
                                 actionClosure: { [weak self] _ in
            guard let self = self else { return }
            self.videoParametersClick()
        }))
        return items
    }()
    
    private lazy var featureClickPanel: FeatureClickPanel = {
        let model = FeatureClickPanelModel()
        model.itemSize = CGSize(width: 56.scale375(), height: 76.scale375())
        model.itemDiff = 12.scale375()
        model.items = featureItems
        let featureClickPanel = FeatureClickPanel(model: model)
        return featureClickPanel
    }()
    
    private func setView() {
        backgroundColor = .g2
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
}

// MARK: Layout

private extension AnchorSettingPanel {
    func constructViewHierarchy() {
        addSubview(titleLabel)
        addSubview(featureClickPanel)
    }
    
    func activateConstraints() {
        snp.remakeConstraints { make in
            if isPortrait {
                make.height.equalTo(350.scale375Height())
            } else {
                make.width.equalTo(375.scale375())
            }
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20.scale375Height())
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(24.scale375Height())
        }
        
        featureClickPanel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32.scale375Height())
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: Action

private extension AnchorSettingPanel {
    private func beautyClick() {
        routerStore.router(action: .present(.beauty))
    }
    
    private func audioEffectClick() {
        routerStore.router(action: .present(.audioEffect))
    }
    
    private func mirrorClick() {
        let isMirror = store.selectCurrent(MediaSelectors.getMirrorState)
        store.dispatch(action: MediaActions.switchMirror(payload: isMirror == true ? false : true))
    }
    
    private func flipClick() {
        let isFrontCamera = store.selectCurrent(MediaSelectors.getFrontCameraState)
        store.dispatch(action: MediaActions.switchCamera(payload: isFrontCamera == true ? .rear : .front))
    }
    
    private func moreSettingClick() {
    }
    
    private func videoParametersClick() {
        routerStore.router(action: .present(.videoSetting))
    }
}

private extension String {
    static let settingTitleText: String = localized("live.anchor.setting.title")
    static let beautyText: String = localized("live.anchor.setting.beauty")
    static let audioEffectsText: String = localized("live.anchor.setting.audio.effects")
    static let flipText: String = localized("live.anchor.setting.flip")
    static let mirrorText: String = localized("live.anchor.setting.mirror")
    static let videoParametersText: String = localized("live.anchor.setting.video.parameters")
    static let moreSettingText: String = localized("live.anchor.setting.more.setting")
}
