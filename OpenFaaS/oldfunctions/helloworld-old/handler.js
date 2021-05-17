"use strict"

const HelloWorld = require("./code/helloworld.js");

module.exports = async (context, callback) => {
    return {status: "done", message: HelloWorld.helloworld()}
}
