## Requirements


## Installation

### Coming Soon: For now install it yourself.

## Author

chbachman, cbachman@bachmangroup.com

## License

CHTable is available under the MIT license. See the LICENSE file for more info.

# Documentation

Implementing UITableViewController is a pain. Most of it is the same code, repeated every time you have to make it.
Now, this allows extensibility, but oftentimes you only want a list backed by an Array or something similar.

Enter CHTable. It manages the UITableView for you, so you can focus on adding custom functionality instead of the boilerplate code.

### General Idea:

```swift
Collection<CHDisplayable> -> CHFilterableTableData -> CHFilterableDataSource -> CHFilterableTableController -> UITableViewController

Collection<CHDisplayable> -> CHTableData -> CHDataSource -> CHTableController -> UITableViewController

Custom Collection ---------------------------> ^^^
```

### Filterable (Search Bars)

This library will take care of search bars for you if you provide a little more information to the types. To make use of this, anything with Filterable in the name allows for searching with the search bar. If you want that, use Filterable, otherwise don't.

### CHDataSource

This turns the collection into methods that CHTableDelegate understands. It has no knowledge of the types passing through it, so it is a perfect gap between CHTableDelegate that doesn't care about types and CHTableData that understands the types inside it.

The easiest way to make one is to use the provided CHTableData class. It takes any collection and turns it into a valid CHDataSource.

However, if your data doesn't fit a collection, implement the CHDataSource yourself.

### Setting up the Delegate:
We need a way to display our wrapped data. How do we do that?

`CHTableController` and `CHFilterableTableController` are the two classes provided that implement `UITableViewDelegate` and `UITableViewDataSource`. These classes turn the intermediary `CHTableDataSouce` to the methods that `UITableViewController` understands.

They each require a data source to display. This can be anything implementing from CHDataSource.

An example use is here:

```swift

```

### CHDisplayable:
`ChDisplayable` is a quick protocol to allow for a title and subtitle used when displaying the object in the table. Most classes require that this protocol is implemented on the type it will be storing.
