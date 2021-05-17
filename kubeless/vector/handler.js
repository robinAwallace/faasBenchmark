"use strict"

const Vector = require("./vector.js");

module.exports = {
    vector: function async (event, context){
        const param = event.data || 0;

        const a = Vector.create(param);
        const b = Vector.create(param);

        const resultBig = Vector.add(a, b);
        const result = Vector.subset(resultBig, 0, 10);

        return result;
    }
}