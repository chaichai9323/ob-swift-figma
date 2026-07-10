import UIKit
import Components
import Onboarding
import SnapKit
import OOGFontKit

class GeneralOBVC: OBBaseViewController {
    
    override var page: OBPage {
        mainPage.obPage
    }

    let mainPage: GeneralOBPage

    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .init("#27242E")
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.init("#27242E99"), for: .disabled)
        btn.setTitle(
            mainPage.nextButtonName,
            for: .normal
        )
        btn.titleLabel?.font = .figtree(.semiBold, fontSize: cx390(17))
        btn.cornerRadius = cx390(32)
        btn.isHidden = mainPage.isHideContinueBtn
        btn.addAction(
            .init(handler: { [weak self] _ in
                self?.clickNext()
            }),
            for: .touchUpInside
        )
        btn.addAction(.init(handler: { [weak self] _ in
            self?.view.isUserInteractionEnabled = false
            self?.delayEnableTouch()
        }), for: .touchDown)
        btn.addAction(.init(handler: { [weak self] _ in
            self?.touchUpOutsideAction()
        }), for: .touchUpOutside)
        return btn
    }()

    var nextBtnEnable: Bool = true {
        didSet {
            let color: UIColor = nextBtnEnable ? .init("#27242E") : .init("#27242E1A")
            nextButton.backgroundColor = color
            nextButton.isEnabled = nextBtnEnable
        }
    }

    lazy var titleLab: UILabel = {
        let res = UILabel(
            frame: .zero,
            text: nil,
            textColor: .init("#27242E"),
            font: .figtree(.bold, fontSize: cx390(30)),
            textAligment: .left
        )
        res.numberOfLines = 0
        return res
    }()

    lazy var bgImageView: UIImageView = {
        let res = UIImageView()
        res.contentMode = .scaleAspectFill
        return res
    }()

    var continueBtnPadding: Constraint?

    private var autoTimer: Timer?

    func autoToNext(delay: Double? = nil) {
        if let t = delay {
            autoTimer = Timer.scheduledTimer(
                withTimeInterval: t,
                repeats: false
            ) { [weak self] tmr in
                self?.clickNext()
                tmr.invalidate()
            }
        } else {
            clickNext()
        }
    }

    func clickNext() {
        container?.onNext(self)
    }

    private func delayEnableTouch() {
        perform(
            #selector(itsTimeEvnableTouch),
            with: nil,
            afterDelay: 0.6
        )
    }
    
    @objc private func itsTimeEvnableTouch() {
        view.isUserInteractionEnabled = true
    }
    
    func touchUpOutsideAction() {
        view.isUserInteractionEnabled = true
    }

    required init(page: GeneralOBPage) {
        self.mainPage = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        [
            bgImageView,
            nextButton,
            titleLab
        ].forEach{ view.addSubview($0) }
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
                .inset(cx390(20))
            make.top.equalTo(view.safeAreaLayoutGuide)
                .offset(cx390(44 + 12))
        }
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(cx390(64))
            make.leading.trailing.equalToSuperview()
                .inset(cx390(ipad: 124, iphone: 20))
            continueBtnPadding = make.bottom.equalToSuperview().constraint
            continueBtnPadding?
                .update(offset: -cx390(ipad: 34, iphone: 34, iphone8: 20))
        }
        
        view.clipsToBounds = true
    }
}
