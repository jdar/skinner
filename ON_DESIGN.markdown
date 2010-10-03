CODE GENERATOR-ATOR
-----

Problem Statement
-----

What do principles of 'good design' look like in a self-evolving codebase? 
How should new generated code be stored in an app, to allow different modes of human oversight? 

Intro
-----

Not all generated code is equal. Some code could be random strings of ones and zeros. This is data. Other code is a 'map'. Neural networks like these have very broad uses, but specific usage. And then there is that third category: generated and EVAL'd code.

As a simple thought experiment, you could have a code generator that randomly generated a list of existing system gems and version numbers, and then tried to execute your code with different combinations (with a bonus for parsimony), thus telling you exactly what your system requirements are. If you only care about certain functionality, you can get a list only for a given testing-functionality.

Now, where do you keep this list of required gems? You have a few options:
* keep in tests/ ... because version spec-ing is fundamentally a testing activity
* generate into tmp/ and consider equally `tainted` to potentially-malicious user input.
* generate (multiple?) into filesystem codebase, call highest-number from an initializer.
* virtualize multiple models / don't preserve except the final output
* virtualize multiple model / keep in database or keystore
* VCS-based codebase manipulations, rolling-back, branching, or combining with other branches

These aren't mutually exclusive, and I see several good ways to do the 'dependency finder' experiment.

[implement a solution?]

Current Solution
-----

For an abstract case of building a model given some unit-tests.


First, when you generate a codefile twice?

    $ skinner build my_model --preserve
    $ created: app/my_model.0.rb
    $ created: app/my_model.rb => app/my_model.0.rb

    [modify a buildcase/ file]
    $ skinner build my_model --preserve 
    $ created: app/my_model.1.rb
    $ modified: app/my_model.rb => app/my_model.1.rb

But if we actually wanted to make an app that safely uses generated code
a not-so-stupid solution might just be an app wide modification of how 'require' works... or even ruby.
Files might be found by 'name + highest number' -- not unique files themselves.

    $ skinner build my_model --no-alias --preserve
    $ created: app/my_model.1.rb

I think this might be more clear while a system is 'evolving' towards a final state, and might allow background 
fitness functions to be run, even while the base 'my_model' is being used by the actual app.

But can we really stretch the definition of 

    $ skinner build my_model --no-alias --preserve
    $ created: app/my_model.1.rb

eventually, I'd like to generate multiple matches at the same time. Not exactly


but hey! It's your funereal. :)

    $ skinner build my_model
    $ modified: app/my_model.rb

Justification
-----

I'm still developing my sense of 'good design' for generated code. My initial sense is that []