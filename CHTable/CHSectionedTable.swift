//
//  File.swift
//  Return
//
//  Created by Chandler on 12/9/16.
//  Copyright © 2016 chbachman. All rights reserved.
//

import UIKit

open class CHSectionTableController<Header, Container>: CHFilterTableController<Container> where Header: CHDisplayable, Container: Collection, Container.Iterator.Element: CHDisplayable {
    public typealias Cell = Container.Iterator.Element

    private var rows = [CellSection<Cell>]()

    let get: (Cell) -> Header?
    let comparison: (Header, Header) -> Bool

    // Comparison checks if the two Headers are the same, and if they are, adds the Cell that created the Header to the Section. 
    // Get returns the Header for the given Cell, allowing comparison on multiple
    init(_ elements: Container, table: UITableView, reuse: String, get: @escaping (Cell) -> Header?, comparison: @escaping (Header, Header) -> Bool) {
        self.get = get
        self.comparison = comparison
        super.init(elements, table: table, reuse: reuse)
    }

    public convenience init (_ other: CHTableController<Container>, get: @escaping (Cell) -> Header?, comparison: @escaping (Header, Header) -> Bool) {
        self.init(other.elements, table: other.tableView, reuse: other.reuse, get: get, comparison: comparison)
    }

    // MARK: Customization
    var updateHeaders = {}

    // Custom Header allows for headers that are not of the same type as the data being sectioned.
    // BEWARE. Because of Typing Issues with allowing a custom typed header, the custom headerSort function not defined in this file will not work. Use the one in this function.
    @discardableResult public func addCustom<NewHeader: CHDisplayable>(header: @escaping (Header) -> NewHeader, headerSort: ((NewHeader, NewHeader) -> Bool)? = nil) -> Self {
        updateHeaders = {
            self.rows = self.rows.map { row in
                guard let rowHeader = row.header as? Header else {
                    return row
                }

                return CellSection(header: header(rowHeader), values: row.values)
            }

            // Sort headers with custom headerSort if passed in.
            if let headerSort = headerSort {
                self.rows.sort(by: { (one, two) -> Bool in
                    return headerSort(one.header as! NewHeader, two.header as! NewHeader)
                })
            }
        }

        return self
    }

    var sectionSort: ((Cell, Cell) -> Bool)?

    // Custom sort of values within a section.
    @discardableResult public func addCustom(sectionSort: @escaping (Cell, Cell) -> Bool) -> Self {
        self.sectionSort = sectionSort
        return self
    }

    // Custom sort of headers. Beware that the sorting will not work if using a custom header
    @discardableResult public func addCustom(headerSort: @escaping (Header, Header) -> Bool) -> Self {
        updateHeaders = {
            self.rows.sort(by: { (one, two) -> Bool in
                return headerSort(one.header as! Header, two.header as! Header)
            })
        }
        return self
    }

    // MARK: Superclass Overrides
    override public func refresh() {
        rows = [CellSection<Cell>]()

        // The filtering should happen first. We then grab and section the already filtered results.
        updateElements()

        for nah in elements {
            // This is each NaH within our current filter.
            guard let value = get(nah) else {
                continue
            }

            var found = false // The new header if the NaH wasn't found.

            for (index, section) in rows.enumerated() {
                guard let sectionHeader = section.header as? Header else {
                    continue
                }

                let returnValue = comparison(value, sectionHeader)

                if returnValue {
                    rows[index].values.append(nah) // NaH was a match for this value, so we add it.
                    found = true
                    break
                }
            }

            if !found { // We didn't find a header, so we create one.
                rows.append(CellSection(header: value, values: [nah]))
            }
        }

        updateHeaders()
        updateSort()

        super.refresh()
    }

    private func updateSort() {
        if let sortMethod = sectionSort {
            rows = rows.map { row in
                CellSection(header: row.header, values: row.values.sorted(by: sortMethod))
            }
        }
    }

    override public func get(_ path: IndexPath) -> Cell {
        return getSection(index: path.section)[path.row]
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse, for: indexPath)
        let element = get(indexPath)

        cell.textLabel?.text = element.title
        cell.detailTextLabel?.text = element.subtitle

        return cell
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSection(index: section).count
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return rows.count;
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getHeader(index: section).title
    }

    // MARK: Convience Methods

    private func getHeaders() -> [CHDisplayable] {
        var arr = [CHDisplayable]()
        for row in rows {
            arr.append(row.header)
        }
        return arr
    }

    private func getHeader(index: Int) -> CHDisplayable {
        return rows[index].header
    }

    private func getSection(index: Int) -> [Cell] {
        return rows[index].values
    }
}

private struct CellSection<Cell> {
    var header: CHDisplayable
    var values: [Cell]
}
