"use strict"

const Sleep = require("./code/sleep.js");

module.exports = async (context, callback) => {
    console.log(context)
    return Sleep.callback(context, function () {
        return {payload: `Hello Sleep for ${context}ms`};
    });
}
