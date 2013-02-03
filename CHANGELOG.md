# Ratistics Changelog

## 0.1.1

* Added *Rank* module with functions related to percentiles
  * percentiles (alias: centiles)
* Added *#min*, *#max*, *#minmax*, and *#relative_risk* functions with block support
* Added *#midrange* function to the *Average* module
* Added tests to confirm ActiveRecord compatability
* Refactored CSV loading for better support across Ruby versions
* Updated all functions with a *sorted* parameter to use a *:sorted* option instead
* Added an options hash to all stats functions
* Added more monkey-patch methods
* Added a *#slice* function to support more collection classes
* Support Hamster classes as return types when loading data from files
* Bagan documenting answers to exercises to *Think Stats* in the *examples* directory
* Added more sample data and sample code to the *examples* directory
* Updated documentation
