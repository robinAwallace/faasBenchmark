'use strict'

const Matrix = require("./code/matrix.js");

module.exports = async (event, context) => {

  const param = event.body || 0;

  const a = Matrix.create(param, param);
  const b = Matrix.create(param, param);

  const resultBig = Matrix.multiply(a, b);
  const result = Matrix.subset(resultBig, 0, 0, 10, 10);

  return context
    .status(200)
    .succeed(result)
}