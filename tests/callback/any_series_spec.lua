require("async.test")

local Timers = require("timers")
local Callback = require("callback")
local wait = require("tests.utils.wait")

describe("Callback.any_series", function()
  async_it("works for result true", function()
    Callback.any_series({ "c", "a", "b" }, function(x, callback)
      Timers.set_timeout(function()
        callback(nil, x == "a")
      end)
    end, function(err, result)
      assert.are.equal(err, nil)
      assert.are.equal(result, true)
      done()
    end)
  end)

  async_it("works for result false", function()
    Callback.any_series({ "c", "a", "b" }, function(x, callback)
      Timers.set_timeout(function()
        callback(nil, x == "f")
      end)
    end, function(err, result)
      assert.are.equal(err, nil)
      assert.are.equal(result, false)
      done()
    end)
  end)

  async_it("can early return", function()
    local calls = 0

    Callback.any_series({ "f", "e", "d", "c", "a", "b" }, function(x, callback)
      calls = calls + 1
      callback(nil, x == "d")
    end, function(err, result)
      assert.are.equal(err, nil)
      assert.are.equal(result, true)
      assert.are.equal(calls, 3)
      done()
    end)
  end)

  it("short circuit", function()
    local call_order = {}

    Callback.any_series({ "a", "b", "c", "d", "e", "f" }, function(x, callback, index)
      Timers.set_timeout(function()
        table.insert(call_order, x)
        callback(nil, x == "c")
      end, index * 15)
    end, function(err, result)
      table.insert(call_order, "callback")
      assert.equal(err, nil)
      assert.equal(result, true)
    end)

    wait(350, function()
      assert.are.same(call_order, { "a", "b", "c", "callback" })
    end)
  end)

  async_it("can error", function()
    Callback.any_series({ "a", "b", "c", "d", "e" }, function(_, callback)
      Timers.set_timeout(function()
        callback("error")
      end)
    end, function(err, result)
      assert.are.equal(err, "error")
      assert.are.equal(result, nil)
      done()
    end)
  end)

  it("can be canceled", function()
    local call_order = {}
    Callback.any_series({ "a", "b", "c", "d", "e" }, function(x, callback, index)
      Timers.set_timeout(function()
        table.insert(call_order, x)
        if x == "c" then
          return callback(false, true)
        end
        callback(nil, false)
      end, index * 15)
    end, function()
      assert.True(false, "should not get here")
    end)

    wait(350, function()
      assert.are.same(call_order, { "a", "b", "c" })
    end)
  end)
end)
