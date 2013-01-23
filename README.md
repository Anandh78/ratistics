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

> gem install ratistics

or add the following line to Gemfile:

> gem 'ratistics'

and run bundle install from your shell.

## Usage

Require Ratistics within your Ruby project:

> require 'ratistics'

then use it:

> sample = [2, 3, 4, 5, 6]
> 
> mean = Ratistics.mean(sample)

When working with sets of complex data use blocks to process the data without copying:

> people = Person.all
> 
> mean = Ratistics.mean(people){|person| person.age}

## Available Functions

* mean
* median
* mode
* variance
* standard_deviation
* range
* frequency
* probability
* probability_mean
* probability_variance

### Test Data

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
