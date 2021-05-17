'use strict'

const Vector = require("./vector.js");

module.exports = async function(context) {
  const param = context.request.body || 0;

  const a = Vector.create(param);
  const b = Vector.create(param);

  const resultBig = Vector.add(a, b);
  const result = Vector.subset(resultBig, 0, 10);

  return {
    status: 200,
    body: result
  };
}