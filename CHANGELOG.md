# Ratistics Changelog

### 0.1.1 *(in progress)*

Release Date: TBD

This release greatly enhanced the tests by adding support for ActiveRecord.
It also greatly enhanced cross-Ruby compatibility by fixing code that
was broken under 1.8.7 and by verifying compatibility with Rubinius.
Finally, several arithmetic and statitical computations.

* Added *Rank* module with functions related to percentiles
  * ranks (alias: percentiles, centiles)
  * linear_rank (aias: percentile, centile)
  * nearest_rank
  * percent_rank
* Added math functions with block support
  * min
  * max
  * minmax
  * relative_risk
* Added collections functions with block support
  * ascending?
  * descending?
  * binary_search (alias: bsearch, half_interval_search)
* Added *#midrange* function to the *Average* module
* Added tests to confirm ActiveRecord compatability
* Refactored CSV loading for better support across Ruby versions
* Updated all functions with a *sorted* parameter to use a *:sorted* option instead
* Added an options hash to all stats functions
* Added more monkey-patch methods
* Added a *#slice* function to support more collection classes
* Support Hamster classes as return types when loading data from files
* Began testing under the Rubinius interpreter
* Bagan documenting answers to exercises to *Think Stats* in the *examples* directory
* Added more sample data and sample code to the *examples* directory
* Updated documentation
