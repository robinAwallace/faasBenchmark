"use strict"

const Sleep = require("./sleep.js");

module.exports = {
    sleep: function async (event, context){
        console.log(event)
        console.log(context)
        return Sleep.callback(event.data, function () {
            return {payload: `Sleep ${event.data}ms`};
        });
    }
}