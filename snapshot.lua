local args = {...}
require("api")

local function main()
    if (#args == 2) or (#args == 3) then
        Snapshot(args[1], args[2], args[3])
    else
        print("Two or three arguments required: the inventory, and the supplier name, [optional] transfer name")
    end
end
main()