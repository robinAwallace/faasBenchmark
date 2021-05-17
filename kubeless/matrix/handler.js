"use strict"

const Matrix = require("./matrix.js");

module.exports = {
    matrix: function async (event, context){
        const param = event.data || 0;

        const a = Matrix.create(param, param);
        const b = Matrix.create(param, param);

        const resultBig = Matrix.multiply(a, b);
        const result = Matrix.subset(resultBig, 0, 0, 10, 10);

        return result;
    }
}