# jshint.vim

A plugin that allow you to run [jshint](http://jshint.org/) from vim.

The contents of a javascript file will be passed through the javascript hint parser after the file's buffer is saved.
Any lint warnings will be placed in the quickfix error window.

## Installation

### Plugin

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/sleistner/vim-jshint.git

### JavaScript runtime

#### Mac OS X

No additional installation steps required /System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc 
is used by default.

#### Linux

Install SpiderMonkey

    $ sudo apt-get install spidermonkey-bin

### Options

`.jshintrc` files in your home directory as well as in your current directory will be loaded automatically.

Your options file(s) should be in JSON format.
See [JSHint docs](http://www.jshint.com/options/) for more information about option names and values.

Example:

    {
        "expr": true, 
        "boss": true
    }

### Commands

- `:JSHint` manually call jshint

- `:JSHintReloadConfiguration` reloads all .jshintrc files.

- `:JSHintToggle` enables or disables jshint automatic validation

### Credits

This plugin makes heavy use of the following sources:

- [http://github.com/joestelmach/javaScriptLint.vim]()
- [http://github.com/hallettj/jslint.vim]()
