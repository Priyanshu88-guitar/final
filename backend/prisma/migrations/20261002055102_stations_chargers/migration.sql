-- CreateTable
CREATE TABLE "charging_stations" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "providerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "city" TEXT,
    "state" TEXT,
    "pincode" TEXT,
    "latitude" REAL NOT NULL,
    "longitude" REAL NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "charging_stations_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chargers" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "stationId" TEXT NOT NULL,
    "chargerCode" TEXT NOT NULL,
    "name" TEXT,
    "chargerType" TEXT NOT NULL,
    "connectorType" TEXT NOT NULL,
    "powerKw" REAL NOT NULL,
    "pricePerHour" REAL NOT NULL DEFAULT 0.0,
    "pricePerKwh" REAL NOT NULL DEFAULT 0.0,
    "status" TEXT NOT NULL DEFAULT 'AVAILABLE',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "chargers_stationId_fkey" FOREIGN KEY ("stationId") REFERENCES "charging_stations" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "chargers_chargerCode_key" ON "chargers"("chargerCode");
