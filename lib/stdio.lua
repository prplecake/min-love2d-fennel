 require("love.event")
 local view = require("lib.fennelview") local event, channel = ... local function _0_(...) if channel then







 local prompt = prompt local function _0_() io.write("> ") io.flush() return io.read("*l") end prompt = _0_
 local function looper(input) if input then


 love.event.push(event, input)
 do local output = channel:demand()

 if (output[2] and ("Error:" == output[2])) then
 print(view(output)) else
 for _, ret in ipairs(output) do
 print(ret) end end end
 io.flush()
 return looper(prompt()) end end return looper(prompt()) end end _0_(...)

 local function start_repl()

 local code = love.filesystem.read("stdio.fnl") local luac = luac
 if code then
 luac = love.filesystem.newFileData(fennel.compileString(code), "io") else

 luac = love.filesystem.read("lib/stdio.lua") end
 local thread = love.thread.newThread(luac)
 local io_channel = love.thread.newChannel()
 local coro = coroutine.create(fennel.repl) local out = out
 local function _2_(val)
 return io_channel:push(val) end out = _2_ local options = options


 local function _3_(kind, ...) return out({kind, "Error:", ...}) end options = {onError = _3_, onValues = out, pp = view, readChunk = coroutine.yield}



 coroutine.resume(coro, options)
 thread:start("eval", io_channel)

 local function _4_(input)
 return coroutine.resume(coro, (input .. "\n")) end love.handlers.eval = _4_ return nil end return {start = start_repl}
