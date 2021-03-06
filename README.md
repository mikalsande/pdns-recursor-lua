# pdns-recursor-lua
Example Lua scripts for the PowerDNS Recursor, some of them might be useful to someone.

## Prerequisites
You need the PowerDNS Recursor v4.0 or newer and Lua 5.1 or LuaJIT.

## Installing
Copy & paste the code you want to use into your own Lua dns filter code.

## Scripts

### block.lua
This script reads a list of domains we want to block from a file and redirects all A or AAAA requsts to a "sorry page".

### malwarefilter.lua
Example of opt-in filtering. Reads a list of IPs that want filtering and a list of known malware domains from two different files. The queries for the malware domains always skip the packet cache so non-filtered clients don't get the domains into the cache.

This could also be implemented with gettag() at the cost of doing Lua for each inbound packet, as far as I understand it.

### rrsetrotate.lua
Makes all RRsets with 2 or more resources in the answer section of a response skip the packet cache. The effect is that the responses from the RRset are answered from the recursor cache and rotated.

### subdomain.lua
An example implementation of a countermeasure for the random subdomain attack. It uses a count-min sketch to track counts of (client IP + domain) pairs. When the NXDOMAIN count for a (client IP + domain) pair goes over a certain threshold the client IP is blocked from generating outbound queries for the specific domain. We do this by adding the (client IP + domain) to a Bloom filter that we check in the preoutquery() Lua hook.

This script uses a Bloom filter and a Count-min sketch. Both datastructures were chosen for this usecase because they use constant space and O(1) query and update. Maybe a bit overengineered, but at least it should scale well. I implemented the [bloom filter](https://github.com/mikalsande/lua-simple-bloom) and [count-min sketch](https://github.com/mikalsande/lua-count-min) myself. The script should work with any other Bloom filter and Count-min sketch by changing a few lines.

TODO - Add a reset for the filter when it reaches capacity or the counter accumulates too much error.
TODO - Add a reset based on absolute time. The count-min sketch should not live too long (5-10 minutes?) and the bloom filter should probably get to live a bit longer (1 hour?).

## Tests
No tests yet, need to figure out a good solution for unit testing these Lua scripts and or functionality testing PowerDNS with the Lua scripts.

## Contributing
Send a pull request if you feel like it. This is just a repo for Lua filter examples for the PowerDNS Recursor.

## Links
These examples were not written in a vacuum, here are links to documentation and other examples. Please let me know if there are any I have missed.
* [Scripting the recursor](https://doc.powerdns.com/md/recursor/scripting/)
* [PowerDNS Wiki Lua Examples](https://github.com/PowerDNS/pdns/wiki/Lua-Examples-(Recursor))
* [Efficient & optional filtering of domains in Recursor 4.0.0](https://blog.powerdns.com/2016/01/19/efficient-optional-filtering-of-domains-in-recursor-4-0-0/)
* [Per device DNS settings: selective parental control](https://blog.powerdns.com/2016/01/27/per-device-dns-settings-selective-parental-control/)

## Authors
See the list of [contributors](https://github.com/mikalsande/pdns-recursor-lua/graphs/contributors) who participated in this project.

## License
Unless another license is specified in the beginning of a file this project is licesed under the Unlicense - see the [LICENSE.md](LICENSE.md) file for details

