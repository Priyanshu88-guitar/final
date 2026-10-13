-- CreateTable
CREATE TABLE "saved_chargers" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "customerId" TEXT NOT NULL,
    "chargerId" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "saved_chargers_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "saved_chargers_chargerId_fkey" FOREIGN KEY ("chargerId") REFERENCES "chargers" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "saved_chargers_customerId_chargerId_key" ON "saved_chargers"("customerId", "chargerId");
