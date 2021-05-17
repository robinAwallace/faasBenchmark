const Fibonacci = require("./fibonacci.js");

module.exports = {
    fibonacci: function async (event, context){
        console.log(event)
        console.log(context)
        return Fibonacci.calcFib(event.data);
    }
}