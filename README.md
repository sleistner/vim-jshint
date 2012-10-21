# vim-jshint

A vim plugin that automatically run [jshint](http://jshint.org/) on the current buffer.

<img src="http://sleistner.github.com/vim-jshint/images/screenshot.png"
  alt="vim-jshint screenshot" width="829" height="581" />

## Usage

The content of the current buffer will be passed to the javascript jshint parser after the buffer is saved.
Lint warnings will be shown in the quickfix error window.

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

`.jshintrc` option files in your home and current directory will be loaded automatically.

Those files should be in JSON format.
See [JSHint docs](http://www.jshint.com/options/) for more information about option names and values.

Example:

    {
        "expr": true,
        "boss": true
    }

### Commands

- `:JSHint` run jshint for current file

- `:JSHintReload` reload all `.jshintrc` option files.

- `:JSHintToggle` enable or disable jshint validation

### Credits

This plugin makes heavy use of the following sources:

- [http://github.com/joestelmach/javaScriptLint.vim]()
- [http://github.com/hallettj/jslint.vim]()
