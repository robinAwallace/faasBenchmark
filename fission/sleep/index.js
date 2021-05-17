const Sleep = require("./sleep.js");

module.exports = async function(context) {
    console.log(context)
    var delay = context.request.body;
    return Sleep.callback(delay, function () {
        return {
            status: 200,
            body: `Hello Sleep for ${delay} ms`
        };
    });
}