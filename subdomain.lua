local bloom = require("bloom")
local countmin = require("countmin")

local preout_blockfilter = bloombits.new(100000, 0.0001)
local countfilter = bloomcount.new(1 / 10000, 0.0001)
local max_nx_count = 200 -- max number of NXDOMAIN for domain+IP before we block

function preoutquery(dq)
  -- get query name
  local qname = dq.qname

  -- only queries with more than two labels, eg. 3.example.com are considered
  -- counted for excessive NXDOMAIN lookups. And since we cut off the first
  -- label the smallest names we are counting have 2 labels, eg. example.com
  if qname:countLabels() > 2 and qname:chopOff() then
    -- concatenate queryname and client IP address to create the key
    local key = string.lower(qname:toStringNoDot() .. dq.localaddr:toString())

    -- if the key has been added to the preout_blockfilter, drop the query
    if preout_blockfilter.check(key) == 1 then
      dq.rcode = -3
      return true
    end
  end

  return false
end

function nxdomain(dq)
  -- get query name
  local qname = dq.qname

  -- only queries with more than two labels, eg. 3.example.com are considered
  -- counted and considered for excessive NXDOMAIN lookups. And since we cut off
  -- the first label the smallest names we are counting have 2 labels, eg.
  -- example.com
  if qname:countLabels() > 2 and qname:chopOff() then
    -- concatenate queryname and client IP address to create the key
    local key = string.lower(qname:toStringNoDot() .. dq.remoteaddr:toString())

    -- don't do anything if the key is already blocked
    if preout_blockfilter.check(key) == 1 then
      return false
    end

    -- get the current count for this key
    local c = countfilter.add(key)
    if c >= max_nx_count then
      -- log who and what we blocked in a Splunk friendly way
      pdnslog('action=block type=nxdomain domain=' .. qname:toStringNoDot()
        .. ' client=' .. dq.remoteaddr:toString() .. ' count=' .. c)
      -- add the key to the boolean bloom filter used for blocking
      preout_blockfilter.add(key)
    end
  end

  return false
end
