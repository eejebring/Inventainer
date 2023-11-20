local folder = "Inventainer/inv/"

function snapshot(peripheralName, supplierName)

    local newPeripheral = peripheral.wrap(peripheralName)
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

    io.output(folder .. peripheralName)
    
    for _, value in pairs(snapshot) do
        io.write(value.name .. "\n")
    end
    io.write(supplierName)

    io.close()
end

function readLines(name)
    local lineList = {}
    for line in io.lines(folder .. name) do
        print(line)
        table.insert(lineList, line)
    end
    return lineList
end

function getSnapshots()
    local snapNames = fs.list(folder)
    local snaps = {}
    for _, name in ipairs(snapNames) do
        local snapData = readLines(name)
        local supplierName = table.remove(snapData)
        local snapObject = {
            ["name"] = name,
            ["supplier"] = supplierName,
            ["slots"] = snapData
        }
        table.insert(snaps, snapObject)
    end
    return snaps
end

function maintain()
    local snapshots = getSnapshots()
    for key, value in ipairs(snapshots) do
        print(key, ": ", value)
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