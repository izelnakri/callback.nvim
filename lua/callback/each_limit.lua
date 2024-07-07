local each_limit = require("callback.internal.each_limit")

---Runs the iteratee function with every element inside the collection **in parallel**. Passes the last result to result_callback. **Errors may stop the iteration early**
---@param collection any[] | table<any, any> Collection of elements to pass as an argument to iteratee function
---@param limit number The maximum number of iteratee calls at a time to run in parallel.
---@param iteratee fun(element: any, callback: fun(err?: any, value?: boolean), index?: number, collection: any[]) A function that runs with each element from the collection, can pass a value to result_callback in parallel, last run callback result gets passed to result_callback.
---@param result_callback? fun(err: any, result: any) Result callback runs when **all iteratee functions run their callback** or **when one iteratee runs callback with error**. **Can be skipped when iteratee runs cancellation**
---@return any callback This will be changed to a Promise-like abstraction in the future
return function(collection, limit, iteratee, result_callback)
  if type(iteratee) ~= "function" then
    return error('Callback.each_limit(collection, iteratee, callback): Expected "iteratee" to be a function')
  end

  return each_limit(limit, collection, iteratee, result_callback)
end
