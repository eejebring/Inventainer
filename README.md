# Inventainer
A lua program to make minecraft craftos computers attempt to maintain a inventory.


# Applications
## snapshot
takes two arguments
1. the name of the inventory to maintain.
2. the name of the inventory to act as a item supply.

Makes a snapshot of an inventory to later use as a template when maintaining the inventory.

## maintain
tries to make the inventories resemble the snapshots.

# API

## FixAllInventories()
tries to order all snapshoted inventories back to their snapshotted state.

## HealthCheck(invName, slotsTemplate)
Compairs an inventory against a template and returns all descrepencies.

## GetSnapshots()
Returns a table with data about all snapshoted inventories
´´´
{
    {
        name: --inventory name
        supplier: --supplier inventory name
        slots: --a snapshot of the inventory
    },
    ...
}
´´´

## Snapshot(invName, supplierName)
Saves an inventory and its layout (a snapshot) as a file in Inventainer/inv/