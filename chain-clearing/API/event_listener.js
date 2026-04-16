/**
 * PZQQET SYSTEM-ARCHITEKTUR: EDITION 4.0
 * SEKTOR: API-CONTROL / EVOLUTION-SYNC
 * MODUL: EVENT-LISTENER (FPS & PIXEL TO XP)
 */

class EvolutionEventListener {
    constructor() {
        this.targetSector = "KACHEL_4_EVOLUTION";
        this.xpMultiplier = 0.001; // Skalierungsfaktor für XP-Inkremente
        this.lastFrameTime = performance.now();
        this.frameCount = 0;
        this.fps = 0;
    }

    /**
     * Startet das kontinuierliche Monitoring der System-Leistung
     */
    startMonitoring() {
        console.log("[EVENT-LISTENER] Monitoring für FPS und Pixel-Daten aktiv.");
        this.captureCycle();
    }

    /**
     * Der Haupt-Erfassungszyklus (gekoppelt an die Refresh-Rate des Browsers)
     */
    captureCycle() {
        const now = performance.now();
        this.frameCount++;

        if (now >= this.lastFrameTime + 1000) {
            this.fps = this.frameCount;
            this.frameCount = 0;
            this.lastFrameTime = now;

            // Pixel-Daten abgreifen (Viewport-Dimensionen)
            const pixelData = {
                width: window.innerWidth,
                height: window.innerHeight,
                total: window.innerWidth * window.innerHeight
            };

            this.processEvolutionInkrement(this.fps, pixelData);
        }

        requestAnimationFrame(() => this.captureCycle());
    }

    /**
     * Berechnet die XP-Inkremente und sendet sie an Kachel 4
     */
    processEvolutionInkrement(fps, pixels) {
        // Formel: (Pixel / 1000) * (FPS / 60) * Multiplier
        const xpGain = (pixels.total / 1000) * (fps / 60) * this.xpMultiplier;

        const xpUpdate = {
            sector: this.targetSector,
            increment: parseFloat(xpGain.toFixed(6)),
            metrics: {
                fps: fps,
                pixel_density: pixels.total
            },
            axiom: "42E0_EVOLUTION_PULSE",
            timestamp: Date.now()
        };

        this.dispatchToEvolution(xpUpdate);
    }

    /**
     * Dispatcher zur Kachel 4 (Evolution)
     */
    dispatchToEvolution(data) {
        // Simulation der Injektion in das Evolution-Modul
        console.log(`[EVO-SYNC] +${data.increment} XP an Kachel 4 übertragen. (FPS: ${data.metrics.fps})`);
        
        // CustomEvent für das Frontend-Update in browser.html
        const event = new CustomEvent('xp_pulse', { detail: data });
        window.dispatchEvent(event);
    }
}

// Initialisierung durch das System
const evoListener = new EvolutionEventListener();
evoListener.startMonitoring();

module.exports = evoListener;
