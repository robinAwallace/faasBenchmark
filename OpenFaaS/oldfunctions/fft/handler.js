"use strict"

const Fft = require("./common/helloworld.js");

module.exports = async (context, callback) => {
    return {status: "done", message: Fft.Fft()}
}
