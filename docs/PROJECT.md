# Salesforce Omni-Channel Inventory Management System - Simplified

## Project Overview

A simplified Omni-Channel Inventory Management system that provides unified inventory visibility and allocation across multiple sales channels (Online, Retail Stores, Call Center, Mobile App) with real-time stock management and intelligent order routing.

## Business Requirements

- Unified inventory view across all sales channels
- Real-time inventory allocation and reservation
- Intelligent order routing based on inventory location
- Multi-location fulfillment capabilities
- Channel-specific inventory rules and prioritization
- Real-time inventory updates across all channels

## Omni-Channel Data Model

### 1. Sales_Channel__c (Custom Object)
**Purpose**: Define different sales channels

| Field Name | Type | Description |
|------------|------|-------------|
| Name | Text(80) | Channel name (Online, Store, Mobile, etc.) |
| Channel_Code__c | Text(20) | Unique channel identifier |
| Channel_Type__c | Picklist | Online, Retail, Call Center, Mobile App |
| Priority__c | Number | Channel priority for inventory allocation |
| Is_Active__c | Checkbox | Channel status |
| Default_Location__c | Lookup(Location__c) | Default fulfillment location |

### 2. Location__c (Custom Object)
**Purpose**: Physical and virtual inventory locations

| Field Name | Type | Description |
|------------|------|-------------|
| Name | Text(80) | Location name |
| Location_Code__c | Text(20) | Unique location code |
| Location_Type__c | Picklist | Warehouse, Store, Drop Ship, Virtual |
| Address__c | Text Area | Physical address |
| Can_Ship__c | Checkbox | Can fulfill online orders |
| Can_Pickup__c | Checkbox | Supports buy online pickup in store |
| Is_Active__c | Checkbox | Location status |
| Latitude__c | Number | GPS coordinate |
| Longitude__c | Number | GPS coordinate |

### 3. Product__c (Custom Object)
**Purpose**: Omni-channel product catalog

| Field Name | Type | Description |
|------------|------|-------------|
| Name | Text(80) | Product name |
| SKU__c | Text(50) | Universal product identifier |
| Description__c | Long Text Area | Product description |
| Category__c | Picklist | Product category |
| Unit_Price__c | Currency | Standard selling price |
| Cost_Price__c | Currency | Cost per unit |
| Allow_Backorder__c | Checkbox | Allow overselling |
| Track_Inventory__c | Checkbox | Inventory tracked product |
| Min_Stock_Level__c | Number | Safety stock level |
| Is_Active__c | Checkbox | Product status |

### 4. Channel_Product__c (Custom Object)
**Purpose**: Channel-specific product settings

| Field Name | Type | Description |
|------------|------|-------------|
| Name | Auto Number | Record name |
| Product__c | Master-Detail(Product__c) | Product reference |
| Sales_Channel__c | Lookup(Sales_Channel__c) | Channel reference |
| Channel_Price__c | Currency | Channel-specific price |
| Is_Available__c | Checkbox | Available in this channel |
| Max_Order_Qty__c | Number | Maximum order quantity per channel |
| Channel_Priority__c | Number | Inventory allocation priority |

### 5. Inventory_Pool__c (Custom Object)
**Purpose**: Real-time inventory tracking per location

| Field Name | Type | Description |
|------------|------|-------------|
| Name | Text(80) | Auto-generated name |
| Product__c | Master-Detail(Product__c) | Product reference |
| Location__c | Lookup(Location__c) | Location reference |
| On_Hand_Qty__c | Number | Physical quantity |
| Available_Qty__c | Number | Available for sale |
| Reserved_Qty__c | Number | Reserved for orders |
| In_Transit_Qty__c | Number | Incoming stock |
| Last_Updated__c | Date/Time | Last inventory update |

### 6. Order__c (Custom Object)
**Purpose**: Omni-channel order management

| Field Name | Type | Description |
|------------|------|-------------|
| Name | Auto Number | Order number |
| Customer__c | Lookup(Account) | Customer account |
| Sales_Channel__c | Lookup(Sales_Channel__c) | Originating channel |
| Order_Date__c | Date/Time | Order creation date |
| Order_Type__c | Picklist | Ship to Home, BOPIS, Ship to Store |
| Status__c | Picklist | Draft, Confirmed, Allocated, Shipped |
| Fulfillment_Location__c | Lookup(Location__c) | Assigned fulfillment location |
| Total_Amount__c | Roll-Up Summary | Order total |
| Customer_Email__c | Email | Customer email |
| Shipping_Address__c | Text Area | Delivery address |

### 7. Order_Line__c (Custom Object)
**Purpose**: Individual order line items

| Field Name | Type | Description |
|------------|------|-------------|
| Name | Auto Number | Line number |
| Order__c | Master-Detail(Order__c) | Order reference |
| Product__c | Lookup(Product__c) | Product reference |
| Quantity__c | Number | Ordered quantity |
| Unit_Price__c | Currency | Item price |
| Line_Total__c | Formula | Quantity × Unit Price |
| Allocated_Location__c | Lookup(Location__c) | Fulfillment location |
| Allocation_Status__c | Picklist | Pending, Allocated, Shipped |

### 8. Inventory_Reservation__c (Custom Object)
**Purpose**: Temporary inventory holds for orders

| Field Name | Type | Description |
|------------|------|-------------|
| Name | Auto Number | Reservation ID |
| Product__c | Lookup(Product__c) | Product reference |
| Location__c | Lookup(Location__c) | Location reference |
| Sales_Channel__c | Lookup(Sales_Channel__c) | Channel reference |
| Order_Line__c | Lookup(Order_Line__c) | Associated order line |
| Reserved_Qty__c | Number | Reserved quantity |
| Expiry_Time__c | Date/Time | Reservation expiration |
| Status__c | Picklist | Active, Expired, Converted, Cancelled |

## Omni-Channel Service Classes

### 1. OmniInventoryService.cls
```apex
public class OmniInventoryService {
    
    // Real-time inventory availability check across all locations
    public static Map<Id, Decimal> getAvailableInventory(Set<Id> productIds, Id channelId) {
        Map<Id, Decimal> availability = new Map<Id, Decimal>();
        
        List<Inventory_Pool__c> inventories = [
            SELECT Product__c, Location__c, Available_Qty__c,
                   Location__r.Can_Ship__c, Location__r.Is_Active__c
            FROM Inventory_Pool__c 
            WHERE Product__c IN :productIds 
            AND Location__r.Is_Active__c = true
            AND Available_Qty__c > 0
        ];
        
        // Aggregate available quantity per product
        for (Inventory_Pool__c inv : inventories) {
            Decimal currentQty = availability.get(inv.Product__c);
            if (currentQty == null) currentQty = 0;
            availability.put(inv.Product__c, currentQty + inv.Available_Qty__c);
        }
        
        return availability;
    }
    
    // Reserve inventory for order (with expiration)
    public static List<Inventory_Reservation__c> reserveInventory(List<Order_Line__c> orderLines, 
                                                                 Id channelId, Integer expiryMinutes) {
        List<Inventory_Reservation__c> reservations = new List<Inventory_Reservation__c>();
        DateTime expiryTime = System.now().addMinutes(expiryMinutes);
        
        for (Order_Line__c line : orderLines) {
            // Find best location for fulfillment
            Id bestLocation = findBestFulfillmentLocation(line.Product__c, 
                                                         line.Quantity__c, channelId);
            
            if (bestLocation != null) {
                // Create reservation
                Inventory_Reservation__c reservation = new Inventory_Reservation__c(
                    Product__c = line.Product__c,
                    Location__c = bestLocation,
                    Sales_Channel__c = channelId,
                    Order_Line__c = line.Id,
                    Reserved_Qty__c = line.Quantity__c,
                    Expiry_Time__c = expiryTime,
                    Status__c = 'Active'
                );
                reservations.add(reservation);
                
                // Update inventory pool
                updateInventoryReservation(line.Product__c, bestLocation, line.Quantity__c);
            }
        }
        
        insert reservations;
        return reservations;
    }
    
    // Intelligent location selection for order fulfillment
    private static Id findBestFulfillmentLocation(Id productId, Decimal quantity, Id channelId) {
        // Get channel preferences
        Sales_Channel__c channel = [SELECT Default_Location__c, Channel_Type__c 
                                  FROM Sales_Channel__c WHERE Id = :channelId];
        
        List<Inventory_Pool__c> availableInventory = [
            SELECT Location__c, Available_Qty__c, Location__r.Location_Type__c,
                   Location__r.Can_Ship__c, Location__r.Latitude__c, Location__r.Longitude__c
            FROM Inventory_Pool__c 
            WHERE Product__c = :productId 
            AND Available_Qty__c >= :quantity
            AND Location__r.Is_Active__c = true
            ORDER BY Available_Qty__c DESC
        ];
        
        // Priority logic:
        // 1. Channel default location if available
        // 2. Nearest store for BOPIS orders
        // 3. Warehouse with highest stock
        
        for (Inventory_Pool__c inv : availableInventory) {
            if (inv.Location__c == channel.Default_Location__c) {
                return inv.Location__c;
            }
        }
        
        // For ship-to-home, prefer warehouses
        if (channel.Channel_Type__c == 'Online') {
            for (Inventory_Pool__c inv : availableInventory) {
                if (inv.Location__r.Location_Type__c == 'Warehouse' && 
                    inv.Location__r.Can_Ship__c) {
                    return inv.Location__c;
                }
            }
        }
        
        // Return first available location
        return availableInventory.isEmpty() ? null : availableInventory[0].Location__c;
    }
    
    // Convert reservation to firm allocation
    public static void confirmInventoryAllocation(List<Id> reservationIds) {
        List<Inventory_Reservation__c> reservations = [
            SELECT Id, Product__c, Location__c, Reserved_Qty__c, Order_Line__c
            FROM Inventory_Reservation__c 
            WHERE Id IN :reservationIds AND Status__c = 'Active'
        ];
        
        List<Order_Line__c> linesToUpdate = new List<Order_Line__c>();
        
        for (Inventory_Reservation__c res : reservations) {
            res.Status__c = 'Converted';
            
            // Update order line with allocation details
            linesToUpdate.add(new Order_Line__c(
                Id = res.Order_Line__c,
                Allocated_Location__c = res.Location__c,
                Allocation_Status__c = 'Allocated'
            ));
        }
        
        update reservations;
        update linesToUpdate;
    }
    
    // Release expired reservations
    public static void releaseExpiredReservations() {
        List<Inventory_Reservation__c> expiredReservations = [
            SELECT Id, Product__c, Location__c, Reserved_Qty__c
            FROM Inventory_Reservation__c 
            WHERE Status__c = 'Active' AND Expiry_Time__c < :System.now()
        ];
        
        for (Inventory_Reservation__c res : expiredReservations) {
            res.Status__c = 'Expired';
            // Release inventory back to available pool
            updateInventoryReservation(res.Product__c, res.Location__c, -res.Reserved_Qty__c);
        }
        
        update expiredReservations;
    }
    
    private static void updateInventoryReservation(Id productId, Id locationId, Decimal quantity) {
        Inventory_Pool__c inventory = [
            SELECT Id, Available_Qty__c, Reserved_Qty__c
            FROM Inventory_Pool__c 
            WHERE Product__c = :productId AND Location__c = :locationId
            LIMIT 1
        ];
        
        inventory.Available_Qty__c -= quantity;
        inventory.Reserved_Qty__c += quantity;
        update inventory;
    }
}
```

### 2. OmniOrderService.cls
```apex
public class OmniOrderService {
    
    // Create omni-channel order with intelligent routing
    public static Order__c createOmniOrder(OrderRequest request) {
        // Create order header
        Order__c order = new Order__c(
            Customer__c = request.customerId,
            Sales_Channel__c = request.channelId,
            Order_Type__c = request.orderType,
            Status__c = 'Draft',
            Customer_Email__c = request.customerEmail,
            Shipping_Address__c = request.shippingAddress
        );
        insert order;
        
        // Create order lines
        List<Order_Line__c> orderLines = new List<Order_Line__c>();
        for (OrderLineRequest lineReq : request.orderLines) {
            orderLines.add(new Order_Line__c(
                Order__c = order.Id,
                Product__c = lineReq.productId,
                Quantity__c = lineReq.quantity,
                Unit_Price__c = getChannelPrice(lineReq.productId, request.channelId)
            ));
        }
        insert orderLines;
        
        // Reserve inventory
        List<Inventory_Reservation__c> reservations = 
            OmniInventoryService.reserveInventory(orderLines, request.channelId, 30);
        
        // Update order status
        order.Status__c = reservations.size() == orderLines.size() ? 'Confirmed' : 'Partial';
        update order;
        
        return order;
    }
    
    // Process Buy Online Pickup In Store (BOPIS)
    public static void processBOPIS(Id orderId, Id storeLocationId) {
        Order__c order = [SELECT Id, Status__c FROM Order__c WHERE Id = :orderId];
        
        List<Order_Line__c> orderLines = [
            SELECT Id, Product__c, Quantity__c, Allocated_Location__c
            FROM Order_Line__c WHERE Order__c = :orderId
        ];
        
        // Check if store has inventory
        Boolean canFulfill = true;
        for (Order_Line__c line : orderLines) {
            Inventory_Pool__c storeInventory = getStoreInventory(line.Product__c, storeLocationId);
            if (storeInventory == null || storeInventory.Available_Qty__c < line.Quantity__c) {
                canFulfill = false;
                break;
            }
        }
        
        if (canFulfill) {
            // Update order for store pickup
            order.Order_Type__c = 'BOPIS';
            order.Fulfillment_Location__c = storeLocationId;
            order.Status__c = 'Ready for Pickup';
            update order;
            
            // Update line allocations
            for (Order_Line__c line : orderLines) {
                line.Allocated_Location__c = storeLocationId;
                line.Allocation_Status__c = 'Allocated';
            }
            update orderLines;
        }
    }
    
    // Real-time inventory sync across channels
    public static void syncInventoryAcrossChannels(Id productId) {
        // Get total available inventory
        Decimal totalAvailable = 0;
        List<Inventory_Pool__c> pools = [
            SELECT Available_Qty__c FROM Inventory_Pool__c 
            WHERE Product__c = :productId
        ];
        
        for (Inventory_Pool__c pool : pools) {
            totalAvailable += pool.Available_Qty__c;
        }
        
        // Update channel availability (simplified - in reality would be more complex)
        List<Channel_Product__c> channelProducts = [
            SELECT Id, Sales_Channel__c, Is_Available__c
            FROM Channel_Product__c WHERE Product__c = :productId
        ];
        
        for (Channel_Product__c cp : channelProducts) {
            cp.Is_Available__c = totalAvailable > 0;
        }
        update channelProducts;
    }
    
    private static Decimal getChannelPrice(Id productId, Id channelId) {
        List<Channel_Product__c> channelProducts = [
            SELECT Channel_Price__c FROM Channel_Product__c 
            WHERE Product__c = :productId AND Sales_Channel__c = :channelId
        ];
        
        if (!channelProducts.isEmpty() && channelProducts[0].Channel_Price__c != null) {
            return channelProducts[0].Channel_Price__c;
        }
        
        // Fallback to standard price
        Product__c product = [SELECT Unit_Price__c FROM Product__c WHERE Id = :productId];
        return product.Unit_Price__c;
    }
    
    private static Inventory_Pool__c getStoreInventory(Id productId, Id locationId) {
        List<Inventory_Pool__c> inventory = [
            SELECT Available_Qty__c FROM Inventory_Pool__c 
            WHERE Product__c = :productId AND Location__c = :locationId
        ];
        return inventory.isEmpty() ? null : inventory[0];
    }
    
    // Request wrapper classes
    public class OrderRequest {
        public Id customerId;
        public Id channelId;
        public String orderType;
        public String customerEmail;
        public String shippingAddress;
        public List<OrderLineRequest> orderLines;
    }
    
    public class OrderLineRequest {
        public Id productId;
        public Decimal quantity;
    }
}
```

### 3. OmniChannelService.cls
```apex
public class OmniChannelService {
    
    // Get unified product catalog with channel-specific data
    public static List<ChannelProductView> getChannelCatalog(Id channelId) {
        List<ChannelProductView> catalog = new List<ChannelProductView>();
        
        List<Channel_Product__c> channelProducts = [
            SELECT Product__c, Product__r.Name, Product__r.SKU__c,
                   Product__r.Description__c, Channel_Price__c,
                   Is_Available__c, Max_Order_Qty__c,
                   Product__r.Unit_Price__c
            FROM Channel_Product__c 
            WHERE Sales_Channel__c = :channelId AND Is_Available__c = true
        ];
        
        Set<Id> productIds = new Set<Id>();
        for (Channel_Product__c cp : channelProducts) {
            productIds.add(cp.Product__c);
        }
        
        // Get inventory availability
        Map<Id, Decimal> availability = OmniInventoryService.getAvailableInventory(productIds, channelId);
        
        for (Channel_Product__c cp : channelProducts) {
            catalog.add(new ChannelProductView(
                cp.Product__c,
                cp.Product__r.Name,
                cp.Product__r.SKU__c,
                cp.Channel_Price__c != null ? cp.Channel_Price__c : cp.Product__r.Unit_Price__c,
                availability.get(cp.Product__c) != null ? availability.get(cp.Product__c) : 0,
                cp.Max_Order_Qty__c
            ));
        }
        
        return catalog;
    }
    
    // Channel performance analytics
    public static ChannelPerformance getChannelPerformance(Id channelId, Date startDate, Date endDate) {
        AggregateResult[] results = [
            SELECT COUNT(Id) orderCount, SUM(Total_Amount__c) totalRevenue
            FROM Order__c 
            WHERE Sales_Channel__c = :channelId 
            AND Order_Date__c >= :startDate AND Order_Date__c <= :endDate
        ];
        
        Decimal orderCount = (Decimal)results[0].get('orderCount');
        Decimal totalRevenue = (Decimal)results[0].get('totalRevenue');
        
        return new ChannelPerformance(orderCount, totalRevenue);
    }
    
    // Store locator for BOPIS
    public static List<StoreLocation> findNearbyStores(Decimal latitude, Decimal longitude, 
                                                      Id productId, Decimal quantity) {
        List<StoreLocation> stores = new List<StoreLocation>();
        
        List<Location__c> nearbyLocations = [
            SELECT Id, Name, Address__c, Latitude__c, Longitude__c, Can_Pickup__c
            FROM Location__c 
            WHERE Location_Type__c = 'Store' AND Can_Pickup__c = true
            AND Is_Active__c = true
            // In real implementation, would use DISTANCE function
            LIMIT 10
        ];
        
        for (Location__c loc : nearbyLocations) {
            // Check inventory availability
            List<Inventory_Pool__c> inventory = [
                SELECT Available_Qty__c FROM Inventory_Pool__c 
                WHERE Location__c = :loc.Id AND Product__c = :productId
                AND Available_Qty__c >= :quantity
            ];
            
            if (!inventory.isEmpty()) {
                stores.add(new StoreLocation(
                    loc.Id, loc.Name, loc.Address__c, 
                    loc.Latitude__c, loc.Longitude__c,
                    inventory[0].Available_Qty__c
                ));
            }
        }
        
        return stores;
    }
    
    // Wrapper classes
    public class ChannelProductView {
        public Id productId;
        public String productName;
        public String sku;
        public Decimal price;
        public Decimal availableQty;
        public Decimal maxOrderQty;
        
        public ChannelProductView(Id id, String name, String sku, Decimal price, 
                                Decimal available, Decimal maxQty) {
            this.productId = id;
            this.productName = name;
            this.sku = sku;
            this.price = price;
            this.availableQty = available;
            this.maxOrderQty = maxQty;
        }
    }
    
    public class ChannelPerformance {
        public Decimal orderCount;
        public Decimal totalRevenue;
        
        public ChannelPerformance(Decimal orders, Decimal revenue) {
            this.orderCount = orders;
            this.totalRevenue = revenue;
        }
    }
    
    public class StoreLocation {
        public Id locationId;
        public String storeName;
        public String address;
        public Decimal latitude;
        public Decimal longitude;
        public Decimal availableStock;
        
        public StoreLocation(Id id, String name, String addr, Decimal lat, 
                           Decimal lng, Decimal stock) {
            this.locationId = id;
            this.storeName = name;
            this.address = addr;
            this.latitude = lat;
            this.longitude = lng;
            this.availableStock = stock;
        }
    }
}
```

## Lightning Web Components

### omniInventoryDashboard.html
```html
<template>
    <lightning-card title="Omni-Channel Inventory Dashboard" icon-name="custom:custom19">
        <div class="slds-m-around_medium">
            <!-- Channel Selector -->
            <lightning-layout multiple-rows>
                <lightning-layout-item size="12">
                    <lightning-combobox
                        name="channelSelector"
                        label="Sales Channel"
                        value={selectedChannel}
                        placeholder="Select Channel"
                        options={channelOptions}
                        onchange={handleChannelChange}>
                    </lightning-combobox>
                </lightning-layout-item>
                
                <!-- Inventory Summary Cards -->
                <lightning-layout-item size="3" class="slds-p-around_small">
                    <div class="summary-card">
                        <div class="slds-text-align_center">
                            <lightning-formatted-number 
                                value={totalProducts}
                                class="slds-text-heading_large">
                            </lightning-formatted-number>
                            <p class="slds-text-body_small">Total Products</p>
                        </div>
                    </div>
                </lightning-layout-item>
                
                <lightning-layout-item size="3" class="slds-p-around_small">
                    <div class="summary-card">
                        <div class="slds-text-align_center">
                            <lightning-formatted-number 
                                value={availableItems}
                                class="slds-text-heading_large">
                            </lightning-formatted-number>
                            <p class="slds-text-body_small">Available Items</p>
                        </div>
                    </div>
                </lightning-layout-item>
                
                <lightning-layout-item size="3" class="slds-p-around_small">
                    <div class="summary-card">
                        <div class="slds-text-align_center">
                            <lightning-formatted-number 
                                value={reservedItems}
                                class="slds-text-heading_large">
                            </lightning-formatted-number>
                            <p class="slds-text-body_small">Reserved Items</p>
                        </div>
                    </div>
                </lightning-layout-item>
                
                <lightning-layout-item size="3" class="slds-p-around_small">
                    <div class="summary-card">
                        <div class="slds-text-align_center">
                            <lightning-formatted-number 
                                value={lowStockItems}
                                class="slds-text-heading_large text-warning">
                            </lightning-formatted-number>
                            <p class="slds-text-body_small">Low Stock Alerts</p>
                        </div>
                    </div>
                </lightning-layout-item>
                
                <!-- Product Inventory Table -->
                <lightning-layout-item size="12" class="slds-p-top_medium">
                    <lightning-datatable
                        key-field="productId"
                        data={inventoryData}
                        columns={columns}
                        hide-checkbox-column>
                    </lightning-datatable>
                </lightning-layout-item>
            </lightning-layout>
        </div>
    </lightning-card>
</template>
```

## Scheduled Jobs & Automation

### OmniInventoryScheduler.cls
```apex
global class OmniInventoryScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Release expired reservations every 15 minutes
        OmniInventoryService.releaseExpiredReservations();
        
        // Sync inventory across channels
        Database.executeBatch(new InventorySyncBatch(), 200);
    }
}

global class InventorySyncBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Product__c WHERE Track_Inventory__c = true]);
    }
    
    global void execute(Database.BatchableContext bc, List<Product__c> products) {
        for (Product__c product : products) {
            OmniOrderService.syncInventoryAcrossChannels(product.Id);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Send completion notification
    }
}
```

## Key Omni-Channel Features

### 1. **Unified Inventory View**
- Real-time inventory visibility across all channels
- Channel-specific product availability
- Centralized inventory pool management

### 2. **Intelligent Order Routing**
- Automatic fulfillment location selection
- Distance-based routing for BOPIS
- Channel priority-based allocation

### 3. **Inventory Reservation System**
- Temporary holds during checkout process
- Automatic expiration and release
- Prevents overselling across channels

### 4. **Multi-Channel Fulfillment**
- Ship from store capabilities
- Buy Online Pickup In Store (BOPIS)
- Drop shipping support

### 5. **Real-Time Synchronization**
- Immediate inventory updates across channels
- Reservation management
- Stock level monitoring

## Integration Points

- **E-commerce Platform**: Real-time inventory sync
- **POS Systems**: Store inventory updates
- **Mobile Apps**: Location-based inventory
- **Call Center**: Unified customer view
- **External Marketplaces**: Channel-specific catalogs