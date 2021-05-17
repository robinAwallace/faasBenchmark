const Fibonacci = require("./fibonacci.js");

module.exports = async function(context) {
    var n = context.request.body;
    var res = Fibonacci.calcFib(n);
    return {
        status: 200,
        body: `${res}`
    };
}