
function parseOptions(optionsString) {
    var options;
    if (optionsString) {
        try {
            options = eval('(' + optionsString + ')');
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
        print(file + '(' + error.line + '): ' + error.id.replace(/\(|\)/g, '') + ': ' + error.reason.toLowerCase());
    }
}
