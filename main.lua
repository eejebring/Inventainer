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
        if value == nil then
            io.write("\n")
        else
            io.write(value.name .. "\n")
        end
    end
    io.write(invName .. "\n")
    io.write(supplierName)

    io.close()
end

function readLines(name)
    local lineList = {}
    for line in io.lines(folder .. name) do
        if line == "" then
            table.insert(lineList, nil)
        else
            table.insert(lineList, line)
        end
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

function slotMatchTemplate(invSlot, slotTemplate)
    if invSlot == nil and slotTemplate == nil then
        return true
    end
    if invSlot == nil then
        return false
    end
    return invSlot.name == slotTemplate
end

function healthCheck(inv, slotsTemplate) 
    local faults = {}
    local invSlots = inv.list()

    for i = 1, inv.size(), 1 do
        if not slotMatchTemplate(invSlots[i], slotsTemplate[i]) then
            table.insert(faults, i)
        end
    end
end

function findSlotWith(itemName, invName)
    local inv = peripheral.wrap(invName)
    for slotNr, slot in pairs(inv.list()) do
        if slotMatchTemplate(slot, itemName) then
            return slotNr
        end
    end
end

function emptySlot(slotNr, inv, supplier)
    if not inv.getItemDetail(slotNr) == nil then
        inv.pushItems(supplier, slotNr)
    end
end

function fillSlot(slotNr, itemName, inv, supplier)
    inv.pullItems(
        supplier,
        findSlotWith(itemName, supplier),
        1,
        slotNr
    )
end

function fixSlots(faults, slotsTemplate, inv, supplier)
    for _, slot in ipairs(faults) do
        print(slot)
        --emptySlot(slot, inv, supplier)
        --fillSlot(slot, slotsTemplate[slot], inv, supplier)
    end
end

function maintain()
    local snapshots = getSnapshots()
    while true do
        for _, snap in ipairs(snapshots) do
            local inv = peripheral.wrap(snap.name)
            --local supplier = peripheral.wrap(snap.supplier)
    
            local faults = healthCheck(inv, snap)
            if not faults == nil then
                fixSlots(faults, snap, inv, snap.supplier)
            end
        end
        break
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