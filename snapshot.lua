local args = {...}
require("api")

local function main()
    if #args == 2 then
        Snapshot(args[1], args[2])
    else
        print("Two arguments required: the inventory, and the supplier name")
    end
end
main()