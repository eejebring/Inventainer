local folder = "Inventainer/inv/"

function Snapshot(invName, supplierName)

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

local function readLines(name)
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

function GetSnapshots()
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

local function slotMatchTemplate(invSlot, slotTemplate)
    if invSlot == nil and slotTemplate == nil then
        return true
    end
    if invSlot == nil then
        return false
    end
    return invSlot.name == slotTemplate
end

function HealthCheck(invName, slotsTemplate) 
    local faults = {}
    local inv = peripheral.wrap(invName)
    local invSlots = inv.list()

    for i = 1, inv.size(), 1 do
        if not slotMatchTemplate(invSlots[i], slotsTemplate[i]) then
            table.insert(faults, i)
        end
    end

    return faults
end

local function findSlotWith(itemName, invName)
    local inv = peripheral.wrap(invName)
    for slotNr, slot in pairs(inv.list()) do
        if slotMatchTemplate(slot, itemName) then
            return slotNr
        end
    end
end

local function emptySlot(slotNr, invName, supplier)
    local inv = peripheral.wrap(invName)
    if not inv.getItemDetail(slotNr) == nil then
        inv.pushItems(supplier, slotNr)
    end
end

local function fillSlot(slotNr, itemName, invName, supplier)
    local inv = peripheral.wrap(invName)
    local supplierSlot = findSlotWith(itemName, supplier)
    if not supplierSlot == nil then
        inv.pullItems(
            supplier,
            supplierSlot,
            1,
            slotNr
        )
    end
end

local function fixInventory(faults, snap)
    for _, slot in ipairs(faults) do
        emptySlot(slot, snap.name, snap.supplier)
        fillSlot(slot, snap.slots[slot], snap.name, snap.supplier)
    end
end

function FixAllInventories()
    local snapshots = GetSnapshots()
    for _, snap in ipairs(snapshots) do
        local faults = HealthCheck(snap.name, snap.slots)
        if not faults == nil then
            fixInventory(faults, snap)
        end
    end
end