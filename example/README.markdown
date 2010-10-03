Quick Start
===

You have internet access, don't you?

Try:

    $ skinner build --photos
    $ skinner build --user


Let's start from scratch(anywhere on your system) and add a buildcase with this:
   `mkdir example2`
   `cd example2`
   `mkdir buildcases`
   `touch buildcases/something.rb`

 # somthing.rb
  class BuildSomething < BuildCase


This one should give you an error:

    $ skinner build --user