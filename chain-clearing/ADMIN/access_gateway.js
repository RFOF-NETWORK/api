/**
 * PZQQET SYSTEM-ARCHITEKTUR: EDITION 4.0
 * SEKTOR: ADMIN-MANAGEMENT (WRITE-CONTROL)
 * MODUL: ACCESS-GATEWAY (UI-TO-NOTARY)
 */

const FeeNotary = require('./MANAGER/fee_notary.js');

class AdminAccessGateway {
    constructor() {
        this.gateway_id = "ADMIN-GATE-01";
        this.master_anchor = "@RFOF-NETWORK";
        this.axiom = "100.000.000%";
        this.is_write_authorized = false;
    }

    /**
     * Prüft die Schreibberechtigung für den fee_notary.
     * Nur aktiv, wenn das Axiom-Siegel intakt ist.
     */
    requestWriteAccess(adminToken) {
        console.log(`[GATEWAY] Zugriffsberechtigung wird geprüft für: ${adminToken}`);
        
        // Mechatronische Verriegelung gegen den Master-Anker
        if (adminToken === this.master_anchor) {
            this.is_write_authorized = true;
            return true;
        }
        return false;
    }

    /**
     * Aktualisiert die Gebühren-Intervalle und spiegelt sie ins UI.
     * Verknüpft Realität 0 (Logik) mit Realität 1 (Visual).
     */
    updateFeeInterval(newInterval) {
        if (!this.is_write_authorized) {
            throw new Error("[SECURITY] Schreibzugriff verweigert. Gateway blockiert.");
        }

        // 1. Logik-Update im Notar (Realität 0)
        const notaryStatus = FeeNotary.adjustInterval(newInterval);

        // 2. UI-Spiegelung (Realität 1)
        const uiUpdate = {
            target: "BROWSER_UI_FEE_DISPLAY",
            status: "SYNCED",
            data: {
                interval: newInterval,
                distribution: "45/42/10/3",
                integrity: this.axiom
            }
        };

        console.warn(`[GATEWAY-SYNC] Gebühren-Intervall auf ${newInterval}ms gesetzt. UI aktualisiert.`);
        return uiUpdate;
    }
}

// Initialisierung des Gateways
const adminGateway = new AdminAccessGateway();

module.exports = adminGateway;
