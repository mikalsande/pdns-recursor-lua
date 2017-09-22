--[[
Makes all RRsets with 2 or more resources in the answer section of a response
skip the packet cache. The effect is that the responses from the RRset are
answered from the recursor cache and rotated.
--]]


-- returns true if the response has more than one resource
-- listed in the answer section
local function mutlipleRecords(dq)
  local count=0
  for _, v in pairs(dq:getRecords()) do
    if v.place == 1 then
      count = count + 1
      if count > 1 then
        return true
      end
    end
  end

  return false
end

function postresolve(dq)
  -- skip the packet cache if the answer contains more than one record in the
  -- answer section. This ensure that answers with multiple resource records are
  -- answered from the recursor cache which rotates RRsets.
  if (dq.qtype == pdns.A or dq.qtype == pdns.AAAA) and mutlipleRecords(dq) then
    dq.variable = true
    multiplerecords_metric:inc()
  end

  -- default, do not rewrite this response
  return false
end


-- metrics
multiplerecords_metric = getMetric("multiplerecord_hits")
