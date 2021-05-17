'use strict'

const Fibonacci = require("./code/fibonacci.js");

module.exports = async (event, context) => {
  const result = {
    'status': 'Received input: ' + JSON.stringify(event.body)
  }

  var res = Fibonacci.calcFib(event.body);

  return context.status(200).succeed(`${res}`)
}

