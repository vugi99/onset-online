
function clamp(val,minval,maxval,valadded)
    if val+valadded <= maxval then
       if val+valadded >= minval then
          val = val+valadded
       else
          val = minval
       end
    else
       val = maxval
    end
    return val
end

function table_count(tbl)
   local nb = 0
   for k, v in pairs(tbl) do
      nb = nb + 1
   end
   return nb
end

function table_last_count(tbl)
   local nb = 0
   for i, v in ipairs(tbl) do
      nb = nb + 1
   end
   return nb
end

function split(str,sep) -- http://lua-users.org/wiki/SplitJoin
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   str:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function O_GetDistanceSquared3D(x, y, z, x2, y2, z2)
   return ((x2 - x)^2 + (y2 - y)^2 + (z2 - z)^2)
end

function O_GetDistanceSquared2D(x, y, x2, y2)
   return ((x2 - x)^2 + (y2 - y)^2)
end