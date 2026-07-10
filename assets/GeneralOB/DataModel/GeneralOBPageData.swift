import Foundation

nonisolated struct GeneralOBPageItem: Hashable, Sendable {
    var title: String?
    var localizedTitle: String?
    var localizedSubtitle: String?
    var icon: String
    
    init(
        title: String? = nil,
        localizedTitle: String? = nil,
        localizedSubtitle: String? = nil,
        icon: String
    ) {
        self.title = title
        self.localizedTitle = localizedTitle
        self.localizedSubtitle = localizedSubtitle
        self.icon = icon
    }
}

struct GeneralOBPageData {
    var pageTitle: NSAttributedString?
    var items: [GeneralOBPageItem]
    
    init(
        pageTitle: NSAttributedString? = nil,
        items: [GeneralOBPageItem] = []
    ) {
        self.pageTitle = pageTitle
        self.items = items
    }
}
