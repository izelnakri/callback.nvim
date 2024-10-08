require("async.test")

local Timers = require("timers")
local Callback = require("callback")
local wait = require("tests.utils.wait")

describe("Callback.map_series", function()
  async_it("works on list collection", function()
    Callback.map_series({ 3, 4, 2, 1 }, function(value, callback, index)
      Timers.set_timeout(function()
        callback(nil, value * 2)
      end, index * 15)
    end, function(err, result)
      assert.are.equal(err, nil)
      assert.are.same(result, { 6, 8, 4, 2 })
      done()
    end)
  end)

  async_it("doesnt mutate the original list collection", function()
    local list = { 3, 4, 2, 1 }
    Callback.map_series(list, function(value, callback)
      callback(nil, value * 2)
    end, function(err, result)
      assert.are.equal(err, nil)
      assert.are.same(result, { 6, 8, 4, 2 })
      assert.are.same(list, { 3, 4, 2, 1 })
      done()
    end)
  end)

  async_it("can error", function()
    Callback.map_series({ 3, 1, 2 }, function(element, callback)
      if element == 1 then
        return callback("error")
      end

      return callback(nil, element * 2)
    end, function(err, result)
      assert.are.equal(err, "error")
      assert.are.same(result, { 6 })
      done()
    end)
  end)

  it("can be cancelled", function()
    local call_order = {}

    Callback.map_series({ 3, 1, 2, 4, 5 }, function(element, callback)
      table.insert(call_order, element)

      Timers.set_timeout(function()
        if element == 2 then
          return callback(false)
        end

        return callback(nil, element * 2)
      end, 25)
    end, function()
      assert.True(false, "should not get here")
    end)

    wait(150, function()
      assert.are.equal(err, nil)
      assert.are.same(call_order, { 3, 1, 2 })
    end)
  end)
end)
