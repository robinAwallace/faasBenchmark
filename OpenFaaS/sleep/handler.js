'use strict'

const Sleep = require("./code/sleep.js");

module.exports = async (event, context) => {
  const result = {
    'status': 'Received input: ' + JSON.stringify(event.body)
  }

  return Sleep.callback(event.body, function () {
    return {payload: `Hello Sleep for ${event.body}ms`};
  });  
}
