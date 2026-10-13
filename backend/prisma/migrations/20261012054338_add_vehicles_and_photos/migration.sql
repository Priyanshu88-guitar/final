-- CreateTable
CREATE TABLE "customer_vehicles" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "customerProfileId" TEXT NOT NULL,
    "make" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "batteryCapacity" REAL,
    "connectorType" TEXT,
    "mileage" REAL,
    "verificationStatus" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "customer_vehicles_customerProfileId_fkey" FOREIGN KEY ("customerProfileId") REFERENCES "customer_profiles" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "provider_setup_photos" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "providerProfileId" TEXT NOT NULL,
    "photoUrl" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "provider_setup_photos_providerProfileId_fkey" FOREIGN KEY ("providerProfileId") REFERENCES "provider_profiles" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_provider_profiles" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "businessName" TEXT NOT NULL,
    "contactPhone" TEXT,
    "contactEmail" TEXT,
    "address" TEXT NOT NULL,
    "city" TEXT,
    "state" TEXT,
    "pincode" TEXT,
    "taxId" TEXT,
    "description" TEXT,
    "verificationStatus" TEXT NOT NULL DEFAULT 'PENDING',
    "setupVerificationStatus" TEXT NOT NULL DEFAULT 'PENDING',
    "logoImage" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "provider_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_provider_profiles" ("address", "businessName", "city", "contactEmail", "contactPhone", "createdAt", "description", "id", "logoImage", "pincode", "state", "taxId", "updatedAt", "userId", "verificationStatus") SELECT "address", "businessName", "city", "contactEmail", "contactPhone", "createdAt", "description", "id", "logoImage", "pincode", "state", "taxId", "updatedAt", "userId", "verificationStatus" FROM "provider_profiles";
DROP TABLE "provider_profiles";
ALTER TABLE "new_provider_profiles" RENAME TO "provider_profiles";
CREATE UNIQUE INDEX "provider_profiles_userId_key" ON "provider_profiles"("userId");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
