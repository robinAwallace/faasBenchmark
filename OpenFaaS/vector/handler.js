'use strict'

const Vector = require("./code/vector.js");

module.exports = async (event, context) => {
  const param = event.body || 0;

  const a = Vector.create(param);
  const b = Vector.create(param);

  const resultBig = Vector.add(a, b);
  const result = Vector.subset(resultBig, 0, 10);

  return context
    .status(200)
    .succeed(result)
}

