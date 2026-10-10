# VOLTERA BACKEND — API DOCUMENTATION (PRODUCTION - PHASE 10)

Base URL: `http://localhost:3000/api/v1` or `http://localhost:3000`

---

## 1. System & Health Endpoints

### 1.1 GET `/health`
- **Auth Required**: No

---

## 2. Authentication & Authorization Endpoints

### 2.1 POST `/auth/signup`
Creates a new Customer or Service Provider account.
- **Role Limits**: `CUSTOMER` or `PROVIDER` only (`ADMIN` signup strictly forbidden).

### 2.2 POST `/auth/otp/verify`
### 2.3 POST `/auth/otp/resend`
### 2.4 POST `/auth/login`
### 2.5 GET `/auth/me`
### 2.6 POST `/auth/logout`
### 2.7 POST `/auth/password/forgot`
### 2.8 POST `/auth/password/reset`
### 2.9 POST `/auth/password/change`

---

## 3. Customer Profile Endpoints

### 3.1 GET `/customer/profile`
### 3.2 PUT/PATCH `/customer/profile`

---

## 4. Provider / Business Profile Endpoints

### 4.1 GET `/provider/profile`
### 4.2 PUT/PATCH/POST `/provider/profile`

---

## 5. Station Management Endpoints (Provider)

### 5.1 POST `/provider/stations`
### 5.2 GET `/provider/stations`
### 5.3 GET `/provider/stations/:stationId`
### 5.4 PATCH `/provider/stations/:stationId`

---

## 6. Charger Management Endpoints (Provider)

### 6.1 POST `/provider/stations/:stationId/chargers`
### 6.2 PATCH `/provider/chargers/:chargerId`

---

## 7. Customer Charger Discovery & Search Endpoints

### 7.1 GET `/chargers`
Discovers and lists active chargers with optional filters and geographic sorting.
- **Parameters Supported**: `latitude`, `longitude`, `radius`, `city`, `state`, `pincode`, `status`, `connectorType`, `chargerType`, `minPower`, `maxPower`, `search`.

### 7.2 GET `/chargers/:chargerId`

---

## 8. Customer Booking & Sessions

### 8.1 POST `/customer/bookings`
Creates a charging booking (Reservation) for a specific time window. Overlapping bookings for the same charger are strictly prevented via serialization.
- **Auth Required**: Yes (`CUSTOMER`)
- **Request Body**:
```json
{
  "chargerId": "chg_uuid",
  "startTime": "2026-10-02T10:00:00.000Z",
  "endTime": "2026-10-02T11:00:00.000Z"
}
```

### 8.2 GET `/customer/bookings`
### 8.3 GET `/customer/bookings/:bookingId`
### 8.4 POST `/customer/bookings/:bookingId/cancel`
### 8.5 POST `/customer/bookings/:bookingId/start-session`
### 8.6 GET `/customer/sessions/active`
### 8.7 POST `/customer/sessions/:sessionId/end`

---

## 9. Provider Booking Management

### 9.1 GET `/provider/bookings`
Retrieves all bookings made against chargers owned by the authenticated Provider.
- **Auth Required**: Yes (`PROVIDER`)

### 9.2 GET `/provider/bookings/:bookingId`
### 9.3 POST `/provider/bookings/:bookingId/accept`
### 9.4 POST `/provider/bookings/:bookingId/reject`

---

## 10. Financial & Payment Endpoints

### 10.1 POST `/customer/payments/create`
### 10.2 GET `/customer/payments`
### 10.3 GET `/customer/transactions`
### 10.4 POST `/payments/webhook`
### 10.5 GET `/provider/earnings`
### 10.6 POST `/provider/payouts`
### 10.7 GET `/provider/payouts`
### 10.8 POST `/provider/bank-account`
### 10.9 GET `/provider/bank-account`

---

## 11. Notifications & Communication

### 11.1 GET `/notifications/preferences`
### 11.2 PATCH `/notifications/preferences`
### 11.3 POST `/notifications/devices/register`
### 11.4 POST `/notifications/devices/unregister`
### 11.5 GET `/notifications`
### 11.6 GET `/notifications/unread-count`
### 11.7 PATCH `/notifications/:notificationId/read`
### 11.8 PATCH `/notifications/read-all`
### 11.9 GET `/notifications/:notificationId`

---

## 12. Bundles & Services

### 12.1 GET `/bundles`
### 12.2 GET `/bundles/:bundleId`
### 12.3 POST `/bundles/:bundleId/purchase`

---

## 13. Emergency Services & Support

### 13.1 GET `/emergency/services`
### 13.2 POST `/emergency/requests`
### 13.3 GET `/emergency/requests`
### 13.4 POST `/support/tickets`
### 13.5 GET `/support/tickets`
### 13.6 GET `/support/tickets/:ticketId`
### 13.7 POST `/support/tickets/:ticketId/messages`

---

## 14. Admin Management

**Security Rules:** 
- Explicit `ADMIN` role is strictly verified natively from active internal sessions. 
- Standalone `CUSTOMER` or `PROVIDER` tokens completely rejected (`403 Forbidden`).

### 14.1 GET `/admin/dashboard`
Generates live aggregated operational totals reporting Active Chargers, Net Settlement Earnings, Total Customers, and Open Tickets dynamically. 

### 14.2 GET `/admin/users`
Retrieves paginated user base stripping password hashes identically across roles. Optionally scoped via `?role=CUSTOMER|PROVIDER`.

### 14.3 PATCH `/admin/users/:id/status`
Suspends, disables, or reactivates identities issuing automatic corresponding Security Notification alerts strictly across target emails/push devices.

### 14.4 GET `/admin/providers`
Retrieves granular nested business profile arrays appending native verification states mappings.

### 14.5 PATCH `/admin/providers/:id/verification`
Promotes/Rejects provider identity validations. Generates deep `AdminAuditLog` events preventing unmanaged modifications concurrently alerting provider networks.
- **Request Body**:
```json
{
  "status": "VERIFIED"
}
```

### 14.6 GET `/admin/stations`
### 14.7 GET `/admin/bookings`