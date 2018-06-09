// This class does all the actual methods for the UITableView
open class CHTableController<Container>: NSObject, UITableViewDelegate, UITableViewDataSource where Container: Collection, Container.Iterator.Element: CHDisplayable {
    public typealias Data = Container.Iterator.Element

    public var tableView: UITableView {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    let reuse: String

    public var elements: Container

    public init (_ elements: Container, table: UITableView, reuse: String) {
        self.reuse = reuse
        self.elements = elements
        tableView = table
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
    }

    public convenience init (_ other: CHTableController<Container>) {
        self.init(other.elements, table: other.tableView, reuse: other.reuse)
    }

    // MARK: CHDataArray
    public func refresh() {
        tableView.reloadData()
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse, for: indexPath)
        let element = get(index: indexPath.row)

        cell.textLabel?.text = element.title
        cell.detailTextLabel?.text = element.subtitle

        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let callback = onSelectCallback {
            callback(get(indexPath))
        }
    }

    private var onSelectCallback: ((Data) -> ())?
    public func onSelect(_ callback: @escaping (Data) -> ()) {
        onSelectCallback = callback
    }



    // MARK: Convience Methods
    private func get(index: Int) -> Data {
        return elements[elements.index(elements.startIndex, offsetBy: index)]
    }

    public func get(_ path: IndexPath) -> Data {
        return get(index: path.row)
    }

    public func getSelections() -> [Data]?{
        if let paths = tableView.indexPathsForSelectedRows {
            return get(paths: paths)
        }

        return nil
    }

    public func getAll() -> [Data]{
        return Array(elements)
    }

    public func get(paths: [IndexPath]) -> [Data]{
        var data = [Data]()
        for path in paths {
            data.append(get(path))
        }
        return data
    }
}
