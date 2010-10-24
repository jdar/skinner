Skinner
===

Don't write code -- FIND base code using BDD-behavioralism. 
"Because someone, somewhere, has already done this shit for you."


Usage
-----

Skinner looks in your current directory for a folder 'buildcases/' which contains tests which are semantically identical to Test::Unit::TestCase classes (inheriting from BuildCase). Once you have specified some unit test, try this:

    $ skinner build

The penitent man* will now have a block of code in `app`. ... looking through this might give you a good idea of what libraries might be useful. At this time, the generated code is not expected to actually work... just suggest approaches or specific libraries.


Installation
------------

    $ sudo gem install skinner

That's (basically) it. For a list of available tasks:

    $ skinner


How It Works
------------

It doesn't. Yet. But theoretically it works by 1) indexing commonalities in Rails repositories on github 2) looking for similar test signatures


License
-------

Copyright (c) 2010 Darius Roberts

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

*
In this case, the penitent man has righteous codefu, internet access, and low expectations.
