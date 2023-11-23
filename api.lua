local folder = "Inventainer/inv/"

function Snapshot(invName, supplierName, transferName)

    if peripheral.wrap(invName) == nil then
        print("invalid peripheral")
        return
    end

    if peripheral.wrap(supplierName) == nil then
        print("invalid supplier")
        return
    end

    if transferName then
        if peripheral.wrap(transferName) == nil then
            print("invalid transferName")
            return
        end
    end

    local snapshot = newPeripheral.list()

    local snapData = {
        ["name"] = invName,
        ["supplier"] = supplierName,
        ["transfer"] = transferName,
        ["slots"] = snapshot
    }

    io.output(folder .. invName)
    io.write(
        textutils.serialise(snapData)
    )
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
        io.input(fileName)
        local snapData = textutils.unserialise(
            io.read()
        )
        table.insert(snaps, snapData)
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
    if not (inv.getItemDetail(slotNr) == nil) then
        inv.pushItems(supplier, slotNr)
    end
end

local function fillSlot(slotNr, itemName, invName, supplier)
    local inv = peripheral.wrap(invName)
    local supplierSlot = findSlotWith(itemName, supplier)
    if not (supplierSlot == nil) then
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
        if #faults then
            fixInventory(faults, snap)
        end
    end
end