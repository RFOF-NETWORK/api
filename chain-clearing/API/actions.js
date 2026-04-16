// ⚙️ ACTIONS.JS: DER MOTOR DES TAKTS
export function initTakt(config) {
    console.log("PZQQET: Takt-Initialisierung gestartet...");
    // Hier wird der Herzschlag des Systems definiert
    return {
        calculateFee: (amount) => amount * config.baseFee,
        validateJoule: (pixels) => pixels * 0.42 // Umrechnung Leistung -> Energie
    };
}

export function triggerExpansion() {
    // Befehl an browser.html, den Interface-Sektor zu öffnen
    const channel = new BroadcastChannel('pzqqet_sync');
    channel.postMessage({ type: 'UI_EXPAND', value: true });
}
