'use strict'

const Matrix = require("./matrix.js");

module.exports = async function(context) {
  const param = context.request.body || 0;

  const a = Matrix.create(param, param);
  const b = Matrix.create(param, param);

  const resultBig = Matrix.multiply(a, b);
  const result = Matrix.subset(resultBig, 0, 0, 10, 10);

  return {
    status: 200,
    body: result
  };
}