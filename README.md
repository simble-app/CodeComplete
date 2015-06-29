CodeComplete
============

### Status

Pre-alpha. Still figuring out what exactly I want out of this... It renders out the completions correctly, but you need to do a little manual work to get it properly into
sublime.

Better Elixir code-completion for Sublime Text by parsing the AST of your application.

### Why?

I didn't like CTags and figured generating/parsing elixir ASTs wouldn't be too hard.


### Current Features

* Method prediction
* Method argument prediction
* Struct preduction (not as method args)

### To Do

* Tests (see below for more) 
* Stop creating/using `completions.sublime-settings` file
* Implement http server
* Store completions to Redis
* Integrate server with Python API
* Support Swift (why stop with Elixir?)

### Install

Use mix, `{:complete_complete, "0.0.1"}` use github as source

### Usage (Mix Task)

`mix code_complete.generate "lib", "web"`

This will create a `completions.sublime-settings` (that isn't valid json (i'll fix it soon)), which you can use for your completions features.

### Tests

I'm a prick, no tests... Right now. This started out as an accidnet.

`There will be test, there will be...`
