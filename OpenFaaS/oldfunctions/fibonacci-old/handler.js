"use strict"

const Fibonacci = require("./code/fibonacci.js");

module.exports = async (context, callback) => {
    console.log(context)
    var res = Fibonacci.calcFib(context);
    return `${res}`
}
