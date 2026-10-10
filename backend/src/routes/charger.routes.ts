import { Router } from 'express';
import { stationController } from '../controllers/station.controller.js';
import { validate } from '../middleware/validate.middleware.js';
import { chargerDiscoveryFiltersSchema } from '../validators/station.validator.js';

const router = Router();

// Public / Customer Discovery Endpoints
// We do not strictly require Auth here to allow public map view, but the project might require it.
// Leaving it without requireAuth if the frontend allows public discovery, or we can add it.
// Given the requirements "customer can list chargers", let's make it public for discovery.
router.get('/', validate({ query: chargerDiscoveryFiltersSchema }), stationController.discoverChargers);
router.get('/:chargerId', stationController.getChargerDetails);

export const chargerRoutes = router;
