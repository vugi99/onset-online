
local testtab = false

AddRemoteEvent("AskTab",function(ply)
    if not testtab then
         local tbl = {}
         tbl[1] = {}
         local tblin = 1
         for i,v in ipairs(GetAllPlayers()) do
            if PlayerData[v] then
               local tblinsert = {}
               tblinsert.name = GetPlayerName(v)
               tblinsert.ping = GetPlayerPing(v)
               tblinsert.cash = PlayerData[v].cash
               tblinsert.bank_cash = PlayerData[v].bank_cash
               tblinsert.level = PlayerData[v].level
               tblinsert.xp = PlayerData[v].xp
               tblinsert.dimension = GetPlayerDimension(v)
               table.insert(tbl[tblin], tblinsert)
            end
            if table_count(tbl[tblin]) > 34 then
               tblin = tblin + 1
               tbl[tblin] = {}
            end
         end
         if table_count(tbl[1]) > 0 then
            CallRemoteEvent(ply, "TabResponse", tbl)
         end
    else
       local tbl = {}
       tbl[1] = {}
       local tblin = 1
       for i = 1, 300 do
          local tblinsert = {}
          tblinsert.name = "test"
          tblinsert.ping = i
          tblinsert.cash = i
          tblinsert.bank_cash = i
          tblinsert.level = i
          tblinsert.xp = i
          tblinsert.dimension = i
          table.insert(tbl[tblin], tblinsert)
          if table_count(tbl[tblin]) > 34 then
             tblin = tblin + 1
             tbl[tblin] = {}
          end
       end
       CallRemoteEvent(ply, "TabResponse", tbl)
    end
end)