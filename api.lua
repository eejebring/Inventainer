local folder = "Inventainer/inv/"

function Snapshot(invName, supplierName, transferName)

    local newPeripheral = peripheral.wrap(invName)

    if newPeripheral == nil then
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
        textutils.serialise(snapData, { compact = true })
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
        io.input(folder .. fileName)
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
    elseif invSlot == nil then
        return false
    elseif slotTemplate == nil then
        return false
    end
    return invSlot.name == slotTemplate.name
end

function HealthCheck(snap) 
    local faults = {}
    local inv = peripheral.wrap(snap.name)
    if inv == nil then
        print(snap.name, "is not a valid peripheral")
        return {}
    end
    local invSlots = inv.list()

    for i = 1, inv.size(), 1 do
        if not slotMatchTemplate(invSlots[i], snap.slots[i]) then
            table.insert(faults, i)
        end
    end

    return faults
end

local function findSlotWith(item, invName)
    local inv = peripheral.wrap(invName)
    for slotNr, slot in pairs(inv.list()) do
        if slotMatchTemplate(slot, item) then
            return slotNr
        end
    end
end

local function emptySlot(slotNr, snap)
    local inv = peripheral.wrap(snap.name)
    if not (inv.getItemDetail(slotNr) == nil) then
        inv.pushItems(snap.supplier, slotNr)
    end
end

local function fillSlot(slotNr, snap)
    local inv = peripheral.wrap(snap.name)
    local supplierSlot = findSlotWith(snap.slots[slotNr], snap.supplier)
    if supplierSlot then
        inv.pullItems(
            snap.supplier,
            supplierSlot,
            1,
            slotNr
        )
    end
end

local function fillTransfer(slotNr, snap)
    local firstEmptySlot = findSlotWith(nil, snap.name)
    if not (firstEmptySlot == nil) then
        if firstEmptySlot < slotNr then
            print("Warning transfer unsuccesful: blocking empty slot at: ", firstEmptySlot)
            return
        end
    end

    local transfer = peripheral.wrap(snap.transfer)
    local supplierSlot = findSlotWith(snap.slots[slotNr], snap.supplier)
    if supplierSlot then
        transfer.pullItems(
            snap.supplier,
            supplierSlot,
            1,
            1
        )
    end
end

local function fixInventory(faults, snap)
    if snap.transfer then
        if faults then
            emptySlot(faults[1], snap)
            fillTransfer(faults[1], snap)
        end
    else
        for _, slot in ipairs(faults) do
            emptySlot(slot, snap)
            fillSlot(slot, snap)
        end
    end
end

function FixAllInventories()
    local snapshots = GetSnapshots()
    for _, snap in ipairs(snapshots) do
        local faults = HealthCheck(snap)
        if 0 < #faults then
            fixInventory(faults, snap)
        end
    end
end

function HealthCheckAll()
    local snapshots = GetSnapshots()
    local faultyInventories = {}
    for _, snap in ipairs(snapshots) do
        local faults = HealthCheck(snap)
        if 0 < #faults then
            table.insert( faultyInventories, snap.name)
        end
    end
    return faultyInventories
end