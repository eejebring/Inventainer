local folder = "Inventainer/inv/"

function snapshot(invName, supplierName)

    local newPeripheral = peripheral.wrap(invName)
    if (newPeripheral == nil) then
        print("invalid peripheral")
        return
    end

    local supplier = peripheral.wrap(supplierName)
    if supplier == nil then
        print("invalid supplier")
        return
    end

    local snapshot = newPeripheral.list()

    io.output(folder .. invName)
    
    for _, value in pairs(snapshot) do
        io.write(value.name .. "\n")
    end
    io.write(invName .. "\n")
    io.write(supplierName)

    io.close()
end

function readLines(name)
    local lineList = {}
    for line in io.lines(folder .. name) do
        table.insert(lineList, line)
    end
    return lineList
end

function getSnapshots()
    local fileNames = fs.list(folder)
    local snaps = {}
    for _, fileName in ipairs(fileNames) do
        local snapData = readLines(fileName)
        local supplierName = table.remove(snapData)
        local invName = table.remove(snapData)
        local snapObject = {
            ["name"] = invName,
            ["supplier"] = supplierName,
            ["slots"] = snapData
        }
        table.insert(snaps, snapObject)
    end
    return snaps
end

function healthCheck(inv, slotsTemplate) 
    local faults = {}
    local invSlots = inv.list()

    for i = 1, inv.size(), 1 do
        if invSlots[i] == nil and slotsTemplate[i] == nil then
            goto continue
        end
        if not invSlots[i] == nil then
            if invSlots[i].name == slotsTemplate[i] then
                goto continue
            end
        end
        table.insert(faults, key)
        ::continue::
    end
end

function maintain()
    local snapshots = getSnapshots()
    for _, x in ipairs(snapshots) do
        for key, y in pairs(x) do
            print(key, ": ", y)
        end
    end
    for _, snap in ipairs(snapshots) do
        local inv = peripheral.wrap(snap.name)
        local supplier = peripheral.wrap(snap.supplier)

        local faults = healthCheck(inv, snap)
        if not faults == nil then
            for _, value in ipairs(faults) do
                print(value)
            end
        end
    end
end

function main()
    print("select an option:\n 1) new snapshot\n 2) maintain inventories\n")

    local running = true
    while running do
        running = false
        local action = read()

        if action == "1" then
            print("Enter peripheral name")
            local peripheralName = read()
            print("Enter supplier name")
            local supplierName = read()
            snapshot(peripheralName, supplierName)

        elseif action == "2" then
            maintain()

        else
            print("invalid option")
            running = true
        end
    end
end
main()