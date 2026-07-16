import UIKit
import Components
import OOGFontKit
import SnapKit

class GeneralOBBaseCell: UICollectionViewCell {
    
    lazy var titleLab: UILabel = {
        let res = UILabel(
            frame: .zero,
            text: nil,
            textColor: .init("#27242ECC"),
            font: .laien(.semiBold, fontSize: cx390(17)),
            textAligment: .left
        )
        res.numberOfLines = 0
        return res
    }()
    
    lazy var icon = UIImageView()
    lazy var checkIcon = {
        let res = UIImageView()
        res.highlightedImage = UIImage(
            named: "GeneralOB/check_select"
        )
        res.image = UIImage(
            named: "GeneralOB/check_normal"
        )
        return res
    }()
    
    lazy var selectedBaseView: OOGGradientBorder = {
        let res = OOGGradientBorder(
            colors: [
                .init("#BECEFF"),
                .init("#BDB6FF"),
                .init("#E7B6FF")
            ],
            start: .init(x: 0, y: 0.5),
            end: .init(x: 1, y: 0.5),
            locations: [0, 1],
            borderLineCorner: cx390(24),
            borderLineWidth: cx390(1.5)
        )
        res.backgroundColor = .init("#F6F5FE")
        res.isHidden = true
        return res
    }()
    
    lazy var baseView: UIView = {
        let res = UIView()
        res.cornerRadius = cx390(24)
        res.addSubview(selectedBaseView)
        selectedBaseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        [checkIcon,titleLab, icon].forEach {
            res.addSubview($0)
        }
        icon.snp.makeConstraints { make in
            make.width.equalTo(cx390(90))
            make.height.equalTo(cx390(84))
            make.trailing.bottom.equalToSuperview()
        }
        checkIcon.snp.makeConstraints { make in
            make.size.equalTo(32)
            make.centerY.equalToSuperview()
            self.checkIconLeading = make.leading.equalToSuperview().constraint
            self.checkIconLeading?.update(offset: -cx390(24))
        }
        titleLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkIcon.snp.trailing)
                .offset(cx390(12))
            make.trailing.equalTo(icon.snp.leading)
        }
        return res
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var checkIconLeading: Constraint?
    
    var isChecked: Bool = false {
        didSet {
            let offset: CGFloat = isChecked ? cx390(20) : -cx390(24)
            self.checkIconLeading?.update(offset: offset)
            checkIcon.isHidden = !isChecked
        }
    }
    
    var data: GeneralOBPageItem? {
        didSet {
            guard let data else {
                return
            }
            icon.image = UIImage(named: data.icon)
            titleLab.text = data.localizedTitle
        }
    }
    
    override var isSelected: Bool {
        didSet {
            selectedBaseView.isHidden = !isSelected
            baseView.layer.borderWidth = isSelected ? 0 : 1
            baseView.layer.borderColor = UIColor("#F1F5F9").cgColor
            baseView.backgroundColor = isSelected ? .clear : .init("#FFFFFF99")
            checkIcon.isHighlighted = isSelected
            isChecked = isSelected
        }
    }
    
    func setupUI() {
        
        contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
                .inset(cx390(ipad: 124, iphone: 20))
        }
    }
}

@MainActor
class GeneralOBCollectionVC: GeneralOBVC, UICollectionViewDelegateFlowLayout {
    
    private var multipleSelect: Bool {
        return mainPage.multipleSelected
    }
    
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let res = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout)
        res.contentInset = .init(top: 0, left: 0, bottom: cx390(28), right: 0)
        res.delegate = self
        res.allowsMultipleSelection = multipleSelect
        res.showsVerticalScrollIndicator = false
        res.backgroundColor = .clear
        //            res.delaysContentTouches = false
        return res
    }()
    
    private(set) lazy var dataSource = UICollectionViewDiffableDataSource<Int, GeneralOBPageItem>(
            collectionView: collection
        ) { [weak self] collectionView, indexPath, item in
            guard let res = self?.cell(collectionView, path: indexPath) else {
                return UICollectionViewCell()
            }
            res.isChecked = self?.multipleSelect == true
            res.data = item
            res.isSelected = self?.selectedData.contains(item) == true
            return res
        }
    
    private var selectedIndexHandler: (([IndexPath]) -> Void)?
    
    var selectedData: [GeneralOBPageItem] = [] {
        didSet {
            nextBtnEnable = !selectedData.isEmpty
        }
    }
    
    private var selectedHandler: (([GeneralOBPageItem]) -> Void)?
    
    func makeSelectItems(
        _ arr: [GeneralOBPageItem],
        block: (([GeneralOBPageItem]) -> Void)?
    ) {
        selectedData = arr
        selectedHandler = block
    }
    
    func makeSelectIndexes(
        _ arr: [IndexPath],
        block: (([IndexPath]) -> Void)?
    ) {
        var res = [GeneralOBPageItem]()
        for idx in arr {
            if let a = dataList[safe: idx.section],
               let b = a[safe: idx.item] {
                res.append(b)
            }
        }
        selectedData = res
        selectedIndexHandler = block
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top)
            make.top.equalTo(titleLab.snp.bottom)
        }
        registerCell()
        
        nextBtnEnable = !selectedData.isEmpty
    }
    
    func loadInitData() {
        dataSource.apply(srcSnapshot, animatingDifferences: false) {
            self.initialAppear(isInit: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        _ = applyDatasource
    }
    
    var dataList: [[GeneralOBPageItem]] {
        return [
            mainPage.pageData.items
        ]
    }
    
    private(set) lazy var srcSnapshot = {
        var snapshot = NSDiffableDataSourceSnapshot<Int, GeneralOBPageItem>()
        let arr = dataList
        for (i, list) in arr.enumerated() {
            snapshot.appendSections([i])
            snapshot.appendItems(list, toSection: i)
        }
        return snapshot
    }()
    
    private lazy var applyDatasource: Bool = {
        loadInitData()
        return true
    }()
    
    private var selectedIndex: [IndexPath] {
        var res = [IndexPath]()
        for (s, list) in dataList.enumerated() {
            for (i, item) in list.enumerated() {
                if selectedData.contains(item) {
                    res.append(
                        IndexPath(
                            item: i,
                            section: s
                        )
                    )
                }
            }
        }
        return res
    }
    
    func initialAppear(isInit: Bool = false) {
        let ani: UICollectionView.ScrollPosition = isInit ? .centeredVertically : .centeredHorizontally
        selectedIndex.forEach { path in
            collection.selectItem(
                at: path,
                animated: false,
                scrollPosition: ani
            )
        }
    }
    
    func registerCell() {
        collection.register(cellWithClass: GeneralOBBaseCell.self)
    }
    
    func cell(_ c: UICollectionView, path: IndexPath) -> GeneralOBBaseCell {
        return c.dequeueReusableCell(
            withClass: GeneralOBBaseCell.self,
            for: path
        )
    }
    
    override func clickNext() {
        
        selectedHandler?(selectedData)
        selectedIndexHandler?(selectedIndex)
        
        super.clickNext()
    }
    
    func select(item: GeneralOBPageItem, indexPath: IndexPath) {
        if mainPage.multipleSelected {
            selectedData.append(item)
        } else {
            selectedData = [item]
        }
        
        if mainPage.isHideContinueBtn {
            clickNext()
        }
    }
    
    func unselect(item: GeneralOBPageItem, indexPath: IndexPath) {
        selectedData.removeAll(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: fullScreenWidth(),
            height: cx390(84)
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cx390(12)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(
            for: indexPath
        ) else {
            return
        }
        select(item: item, indexPath: indexPath)
        
        if !mainPage.cellHeightIsConsistent {
            collectionView.performBatchUpdates {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(
            for: indexPath
        ) else {
            return
        }
        unselect(item: item, indexPath: indexPath)
        
        if !mainPage.cellHeightIsConsistent {
            collectionView.performBatchUpdates {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
}

