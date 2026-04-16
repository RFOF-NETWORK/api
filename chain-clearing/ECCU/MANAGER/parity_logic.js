/**
 * PZQQET SYSTEM-ARCHITEKTUR: EDITION 4.0
 * SEKTOR 5: CENTRAL VALUE MANAGEMENT (ECCU)
 * MODUL: PARITY-ERZWUNGUNG (HARDCODED)
 */

class ParityLogic {
    constructor() {
        // UNVERÄNDERLICHE BASIS-KONSTANTEN (AXIOME)
        this.STORAGE_UNIT_TB = 2.0;       // 2 Terabyte
        this.ECCU_VALUE = 1.0;            // 1 ECCU
        this.EURO_PARITY = 2.50;          // 2,50 Euro
        
        this.sectorStatus = "STABLE";
    }

    /**
     * Die Parity-Validierung
     * Berechnet den Soll-Wert basierend auf dem Speicher und gleicht ihn ab.
     */
    validateValue(storageAmountTB, currentEccuBalance) {
        console.log(`[ECCU] Validiere Parity: ${storageAmountTB} TB gegen ${currentEccuBalance} ECCU...`);

        // Berechnung: Soll-ECCU = Vorhandene TB / 2
        const expectedEccu = storageAmountTB / this.STORAGE_UNIT_TB;
        const expectedEuroValue = expectedEccu * this.EURO_PARITY;

        // Prüfung auf Abweichung (Präzision bis 10^-8 für Qubit-Sicherheit)
        if (Math.abs(expectedEccu - currentEccuBalance) > 0.00000001) {
            return this.triggerTaktReset(expectedEccu, currentEccuBalance);
        }

        console.log(`[ECCU] Parity bestätigt: 1 ECCU = 2,50€ | Realwert: ${expectedEuroValue}€`);
        return {
            status: "VALIDATED",
            euroEquivalent: expectedEuroValue,
            level: "AAA"
        };
    }

    /**
     * Takt-Reset Trigger
     * Wird bei jeder mathematischen Inkonsistenz sofort ausgelöst.
     */
    triggerTaktReset(expected, actual) {
        this.sectorStatus = "RESET_REQUIRED";
        
        const alarm = {
            error: "PARITY_VIOLATION",
            expected_eccu: expected,
            actual_eccu: actual,
            timestamp: Date.now(),
            action: "EMERGENCY_TAKT_RESET_0"
        };

        console.error("!!! KRITISCHE ABWEICHUNG DETEKTIERT !!!");
        console.table(alarm);

        // Brücke zum globalen Takt-Manager (index.html)
        if (window.core) {
            window.core.currentTakt = 0; // Sofortiger Fallback auf Takt 0
            console.warn("[SYSTEM] Globaler Takt wurde auf 0 zurückgesetzt.");
        }

        return { status: "FAILED", action: "RESET" };
    }

    /**
     * Hilfsfunktion für die Umrechnung (Read-Only für API-Abfragen)
     */
    getConversionRate() {
        return `${this.STORAGE_UNIT_TB} TB = ${this.ECCU_VALUE} ECCU = ${this.EURO_PARITY} EUR`;
    }
}

// Initialisierung der Parity-Logik
const eccuParity = new ParityLogic();

// Test-Lauf: 4 TB müssen 2 ECCU (5,00€) ergeben
eccuParity.validateValue(4.0, 2.0);

// Fehler-Simulation: 2 TB ergeben fälschlicherweise 1.1 ECCU
// eccuParity.validateValue(2.0, 1.1);
