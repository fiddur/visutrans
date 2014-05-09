
This is a small hack to get an overview of the transactions to and from my bank account.

This is just a prototyped concept-test for my own needs, put here 'as is'.  It is not clean, nor
well structured.  If others are interrested in using and/or developing it, there's a lot to be done
:)

## Dependencies

* bundle
* bower


## Installation

- Install neo4j 2.0.3:
  On linux: `rake install_neo`
  Otherwise, install and put it in vendor/neo4j-community-2.0.3 (if you want rake to start it).

  rake install

- Install the rest
  `rake install`

- Start neo4j
  `rake start_neo` if you've installed it in vendor.  Otherwise some kind of `bin/neo4j start`.


## Starting and using VisuTrans

`rake start`




## Todo

* Make categorizing use ajax calls (creating category, fetching more recipients, categorizing
  recipient).
* Use angular js, with an angular chart binded to the right data.
* Make it possible to hide/show categories in the sums.
* Print out the sums in bootstrap rows per category instead (no_periods / 12 for bootstrap grid).
* Split up the models into separate files.
* Move the importer into a lib, to enable more importers and a web/rest interface.
* Make a page to drop the transaction exports (SEB xlsx) into.
* Move this todo to github wishlist issues? :P
