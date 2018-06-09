open class CHFilterTableController<Container>: CHTableController<Container>, UISearchBarDelegate, UISearchResultsUpdating where Container: Collection, Container.Iterator.Element: CHDisplayable {
    var searchController = UISearchController(searchResultsController: nil)

    private var unfiltered: Container
    private var filtered: Container?

    public var isSearchActive = false {
        didSet {
            updateElements()
        }
    }

    public override init(_ elements: Container, table: UITableView, reuse: String) {
        self.unfiltered = elements
        super.init(elements, table: table, reuse: reuse)
    }

    // MARK: Convenience Methods
    override public func refresh() {
        tableView.reloadData()
        updateSearchResults(for: searchController)
    }

    // MARK: UISearchBarDelegate, UISearchResultsUpdating
    @discardableResult public func addSearchBar(viewController: UIViewController? = nil) -> UISearchController {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false

        tableView.tableHeaderView = searchController.searchBar

        if let viewController = viewController {
            viewController.definesPresentationContext = true
            viewController.extendedLayoutIncludesOpaqueBars = true
        }

        return searchController
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearchActive = true
        refresh()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchActive = false
        refresh()
    }

    public func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }

        filter(text: text)

        tableView.reloadData()
    }

    private var customFilter: ((String, Container) -> Container)?

    public func addCustom(filter: @escaping (String, Container) -> Container) {
        self.customFilter = filter
    }

    public func filter(text: String) {
        if let filter = customFilter {
            filtered = filter(text, unfiltered)
            updateElements()
        }
    }

    func updateElements() {
        // If we don't have a filtered array, don't bother sending it back.
        guard let filtered = filtered else {
            elements = unfiltered
            return
        }

        if isSearchActive {
            elements = filtered
        } else {
            elements = unfiltered
        }
    }
}
