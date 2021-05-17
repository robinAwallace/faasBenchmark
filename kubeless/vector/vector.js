'use strict';

const clock = require('./clock.js');

exports.add = (v1, v2) => {
  const t0 = clock.clock();

  let result = [];
  for (let i = 0; i < v1.length; i++) {
    result[i] = v1[i] + v2[v1.length - i - 1];
  }

  console.log("Vector.add time: " + clock.clock(t0));

  //console.table(mResult)

  return result;
};

exports.create = (n) => {
  const t0 = clock.clock();

  let vector = [];
  for (let i = 0; i < n; i++) {
    vector[i] = i;
  }

  console.log("Vector.create time: " + clock.clock(t0));

  //console.table(matrix)

  return vector;
};

exports.subset = (v1, offset_x, width) => {
  const t0 = clock.clock();

  let result = [];
  for (let i = offset_x; i < v1.length && i < offset_x + width; i++) {
    result[i - offset_x] = v1[i + offset_x];
  }

  console.log("Vector.subset time: " + clock.clock(t0));

  //console.table(mResult)

  return result;
};

