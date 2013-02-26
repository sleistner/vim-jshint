/*
    This function is loosely based on the one found here:
    http://www.weanswer.it/blog/optimize-css-javascript-remove-comments-php/
*/
function removeComments(str) {
    str = ('__' + str + '__').split('');
    var mode = {
        singleQuote: false,
        doubleQuote: false,
        regex: false,
        blockComment: false,
        lineComment: false,
        condComp: false
    };
    for (var i = 0, l = str.length; i < l; i++) {

        if (mode.regex) {
            if (str[i] === '/' && str[i-1] !== '\\') {
                mode.regex = false;
            }
            continue;
        }

        if (mode.singleQuote) {
            if (str[i] === "'" && str[i-1] !== '\\') {
                mode.singleQuote = false;
            }
            continue;
        }

        if (mode.doubleQuote) {
            if (str[i] === '"' && str[i-1] !== '\\') {
                mode.doubleQuote = false;
            }
            continue;
        }

        if (mode.blockComment) {
            if (str[i] === '*' && str[i+1] === '/') {
                str[i+1] = '';
                mode.blockComment = false;
            }
            str[i] = '';
            continue;
        }

        if (mode.lineComment) {
            if (str[i+1] === '\n' || str[i+1] === '\r') {
                mode.lineComment = false;
            }
            str[i] = '';
            continue;
        }

        if (mode.condComp) {
            if (str[i-2] === '@' && str[i-1] === '*' && str[i] === '/') {
                mode.condComp = false;
            }
            continue;
        }

        mode.doubleQuote = str[i] === '"';
        mode.singleQuote = str[i] === "'";

        if (str[i] === '/') {

            if (str[i+1] === '*' && str[i+2] === '@') {
                mode.condComp = true;
                continue;
            }
            if (str[i+1] === '*') {
                str[i] = '';
                mode.blockComment = true;
                continue;
            }
            if (str[i+1] === '/') {
                str[i] = '';
                mode.lineComment = true;
                continue;
            }
            mode.regex = true;

        }

    }
    return str.join('').slice(2, -2);
}

function parseOptions(optionsString) {
    var options;
    if (optionsString) {
        try {
            options = JSON.parse(removeComments(optionsString));
        } catch (e) {
            options = {};
        }
    }
    return options || {};
}

function getOptions(args) {
    var globalOptions = parseOptions(args[1]);
    var localOptions = parseOptions(args[2]);

    for (var option in localOptions) {
        globalOptions[option] = localOptions[option];
    }
    return globalOptions;
}

function readSTDIN() {
    var line = readline(),
        input = [],
        emptyCount = 0,
        i;

    while (emptyCount < 25) {
        input.push(line);
        if (line) {
            emptyCount = 0;
        } else {
            emptyCount += 1;
        }
        line = readline();
    }

    input.splice(-emptyCount);
    return input.join("\n");
}

var body = readSTDIN();
var options = getOptions(arguments);

if (!JSHINT(body, options)) {
    var file = arguments[0],
        len = JSHINT.errors.length,
        error;
    for (var i = 0; i < len; i++) {
        error = JSHINT.errors[i];
        try {
            //print(file + '(' + error.line + '): ' + error.id.replace(/\(|\)/g, '') + ': ' + error.reason.toLowerCase());
            if (error) {
                print(file + '(' + error.line + '): ' + error.reason);
            }
        } catch (ex) {
            print(JSON.stringify(error, null, 2));
        }
    }
}
