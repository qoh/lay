-- This is bad.

return function(base)
  local class

  if base == nil then
    local index = {}
    class = {
      __instance = index,
      __index = index
    }
  else
    class = {
      __instance = {},
      __index = function(t, k, v)
        if class.__instance[k] ~= nil then
          return class.__instance[k]
        end

        return base.__instance[k]
      end
    }
  end

  setmetatable(class, {
    __call = function(mt, ...)
      return mt:new(...)
    end
  })

  return class
end
