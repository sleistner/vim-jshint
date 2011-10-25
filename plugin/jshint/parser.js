load(arguments[0]);

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

var body = readSTDIN() || arguments[2];
if (!JSHINT(body)) {
    var file = arguments[1], len = JSHINT.errors.length, error;
    for (var i = 0; i < len; i++) {
        error = JSHINT.errors[i];
        print(file + '(' + error.line + '): ' + error.id.replace(/\(|\)/g, '') + ': ' + error.reason.toLowerCase());
    }
}
