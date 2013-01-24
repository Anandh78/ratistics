# Ratistics - Ruby Statistics Gem [![Build Status](https://secure.travis-ci.org/jdantonio/ratistics.png)](http://travis-ci.org/jdantonio/ratistics?branch=master) [![Dependency Status](https://gemnasium.com/jdantonio/ratistics.png)](https://gemnasium.com/jdantonio/ratistics)

Ratistics is a purely functional library that provides basic
statistical computation functions to Ruby programmers. It is
intended for small data sets only. This gem was designed for
simplicity. Only basic consideration was given to performance.

* [RubyGems project page](https://rubygems.org/gems/ratistics)
* [Source code on GitHub](https://github.com/jdantonio/ratistics )
* [YARD documentation on RubyDoc.org](http://rubydoc.info/github/jdantonio/ratistics/master/frames )

## About

A [friend](https://github.com/joecannatti) of mine convinced me
to learn statistics but I'm too lazy to learn [R](http://www.r-project.org/).
I started my statistics journey by reading the excellent book
[*Think Stats*](http://greenteapress.com/thinkstats/) by Allen B.
Downey and didn't want to do the exercises in Python. I looked for a
Ruby statistics library but couldn't find one that I liked.
So I decided to write my own.

### Purely Functional

This entire library is written in a purely functional style. All
functions are stateless, referentially transparent, and side-effect
free. When possible they are also idempotent. Only the sort order
of result sets may vary. The automated tests are run against
frozen data to ensure immutability.

Ruby does not support functions as first-class objects the way
purely functional languages do. Ruby's blocks are a pretty
close approximation. All the functions in this library accept
an optional block parameter. This supports computation against
complex data types without excessive data copying. I've followed
the same block idiom as much as possible to make the library as
consistent.

### Pure Ruby

Ratistics is written in pure Ruby and has no runtime gem dependencies.
It should work with any Ruby interpreter compliant with MRI 1.6.7 or
newer, but only MRI 1.9.x is officially supported.The test suite is
regularly run against several versions of Ruby so you should have
good results with any of the following:

* ruby-1.8.7
* ruby-1.9.2
* ruby-1.9.3
* jruby-1.6.7
* jruby-1.6.7.2
* jruby-1.6.8
* jruby-1.7.0
* ree-1.8.7

### Sorting

Some statistical computations require sorted data. In these cases
this library assumes the data is unsorted and calls the *#sort*
method on the data set. If the data passed to the function is
already sorted then an unnecessary performace penalty will occur.
To mitigate this, every function that requires sorted data provides
an optional *sorted* parameter which defaults to false. When set
to *true* it indicates the data is already sorting and the sort
step is skipped.

A problem occurs when the data set does not support a natural sort
order. The Ruby idiom for this situation is to accept a block which
specifies the sort operation. Unfortunately, passing two blocks to
a function is cumbersome in Ruby so the functions that require sorting
must depend on the natural sort order only. For simplicity and
consistency, when a block is passed to a function that requires
sorted data it is assumed that natural sorting is impossible.
Subsequently the sort operation is skipped regardless of the value
of the *sorted* parameter.

#### Hamster

The main drawback of side-effect free functions is that in
non-functional languages they can lead to excessive data copying.
Some of the functions in this library, specifically ones that must
sort the data, may suffer from this. For better performance I highly
recommend using the [Hamster](https://github.com/jdantonio/hamster)
library of "efficient, immutable, thread-safe collection classes."
Hamster implements the Ruby [Enumerable](http://ruby-doc.org/core-1.9.3/Enumerable.html)
interface so all the functions in this library support the appropriate
Hamster classes. Hamster is not a runtime dependency of this gem but
the test suite explicitly tests Hamster compatibality.

## Installation

Install from RubyGems:

    gem install ratistics

or add the following line to Gemfile:

    gem 'ratistics'

and run bundle install from your shell.

## Usage

Require Ratistics within your Ruby project:

    require 'ratistics'

then use it:

    sample = [2, 3, 4, 5, 6]
    
    mean = Ratistics.mean(sample)

When working with sets of complex data use blocks to process the data without copying:

    people = Person.all
    
    mean = Ratistics.mean(people){|person| person.age}

### Shock the Monkey

I'm normally not a fan of monkey-patching classes from the Ruby standard library.
But there could be times when it would be convenient to have statistics functions
as instance methods on Array. I've provided this monkey-patching, but not by default.
Simply requiring 'ratistics' will not mess with any of the Ruby collection classes.
For that fun you must

    require 'ratistics/monkey'

Then you can go to town:

    sample = [2, 3, 4, 5, 6]
    
    mean = sample.mean

### Available Functions

* delta
* mean (average, avg)
* truncated_mean
* median
* mode
* variance (var)
* standard_deviation (std_dev, stddev)
* range
* frequency
* probability (pmf)
* normalize_probability (normalize_pmf)
* probability_mean (pmf_mean)
* probability_variance (pmf_variance)

### A Worked Example

The following code answers the big question from page 2 of *Think Stats*: Do first babies arrive late?

The first step in this solution is to load the NSFG test data (see below). The file
[survey.rb](https://github.com/jdantonio/ratistics/blob/master/data/survey.rb)
provides utilities for reading and processing the data. The function `Survey.get_pregnancy_data`
returns an array of hashes. Each hash represents a single pregnancy and has the following
structure:

    {:caseid => 1,
     :nbrnaliv => 1,
     :babysex => 1,
     :birthwgt_lb => 8,
     :birthwgt_oz => 13,
     :prglength => 39,
     :outcome => 1,
     :birthord => 1,
     :agepreg => 3316,
     :finalwgt => 6448.271111704751}

Once the data is loaded it can be easily processed:

    # load the data
    sample = Survey.get_pregnancy_data
    sample.count #=> 13593 

    # filter for first-borns
    first = sample.filter{|item| item[:birthord] == 1}
    first.count #=> 4413

    # filter for non-first-borns
    not_first = sample.filter{|item| item[:birthord] > 1}
    not_first.count #=> 4735

    # calculate mean pregnancy lengths
    Ratistics.mean(sample){|item| item[:prglength]} #=> 29.531229309203265 
    Ratistics.mean(first){|item| item[:prglength]} #=> 38.60095173351461 
    Ratistics.mean(not_first){|item| item[:prglength]} #=> 38.52291446673706

    # calculate the variance of pregnancy lengths
    Ratistics.variance(sample){|item| item[:prglength]} #=> 190.49562224367648 
    Ratistics.variance(first){|item| item[:prglength]} #=> 7.792947202066306 
    Ratistics.variance(not_first){|item| item[:prglength]} #=> 6.84123839078341

    # calculate the standard deviation of pregnancy lengths
    Ratistics.standard_deviation(sample){|item| item[:prglength]} #=> 13.8020151515522 
    Ratistics.standard_deviation(first){|item| item[:prglength]} #=> 2.7915850698243654 
    Ratistics.standard_deviation(not_first){|item| item[:prglength]} #=> 2.6155761106844913

    # calculate the frequency of pregnancy lengths
    sample_freq = Ratistics.frequency(sample){|item| item[:prglength]} #=> {39=>4744, 38=>609, ...} 
    first_freq = Ratistics.frequency(first){|item| item[:prglength]} #=> {39=>2114, 38=>272, ...} 
    not_first_freq = Ratistics.frequency(not_first){|item| item[:prglength]} #=> {39=>2579, 40=>580, ...} 

Once you have the frequency data you can use any charting/graphing library to
create a histogram to compare birth rates. The file
[histogram.rb](https://github.com/jdantonio/ratistics/blob/master/data/histogram.rb)
shows how to use [Gruff](https://github.com/topfunky/gruff) to create this:

![histogram](https://raw.github.com/jdantonio/ratistics/master/data/histogram.png)

## Test Data

The test data shipped with this gem is freely available from
the Centers for Disease Control and Prevention
[National Survey of Family Growth](http://www.cdc.gov/nchs/nsfg.htm).
It is the test data used in the aforementioned book *Think Stats*.

## Copyright

Ratistics is Copyright &copy; 2013 Jerry D'Antonio. It is free
software and may be redistributed under the terms specified in
the LICENSE file.

## License

Released under the MIT license.

http://www.opensource.org/licenses/mit-license.php  

> Permission is hereby granted, free of charge, to any person obtaining a copy  
> of this software and associated documentation files (the "Software"), to deal  
> in the Software without restriction, including without limitation the rights  
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
> copies of the Software, and to permit persons to whom the Software is  
> furnished to do so, subject to the following conditions:  
> 
> The above copyright notice and this permission notice shall be included in  
> all copies or substantial portions of the Software.  
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  
> THE SOFTWARE.  
