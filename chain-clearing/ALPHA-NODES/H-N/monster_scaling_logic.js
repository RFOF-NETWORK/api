/**
 * PZQQET SYSTEM-ARCHITEKTUR: EDITION 4.0
 * SEKTOR: ALPHA-NODES (H-N)
 * MODUL: MONSTER-SCALING (UNENDLICHE KASKADE)
 */

class MonsterScaling {
    constructor() {
        this.alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        this.currentSequence = "A";
        this.activeNodes = [];
    }

    /**
     * Berechnet die nächste alphabetische Stufe (A -> Z -> AA -> AB...)
     * @param {string} current - Die aktuelle Node-Bezeichnung
     */
    generateNextSequence(current) {
        let chars = current.split("");
        let i = chars.length - 1;

        while (i >= 0) {
            let charIndex = this.alphabet.indexOf(chars[i]);
            
            if (charIndex < 25) {
                // Inkrementiere aktuellen Buchstaben
                chars[i] = this.alphabet[charIndex + 1];
                return chars.join("");
            } else {
                // Setze auf 'A' zurück und gehe eine Stelle nach links
                chars[i] = "A";
                i--;
            }
        }

        // Wenn alle Stellen 'Z' waren, füge ein neues 'A' hinzu (z.B. Z -> AA)
        return "A" + chars.join("");
    }

    /**
     * Erstellt einen neuen Takt-Raum (0-10) für die neue Sequenz
     */
    spawnNewTaktRoom(sequence) {
        console.log(`[MONSTER-SCALING] Generiere neuen Takt-Raum für Node: ${sequence}`);
        
        const newSpace = {
            id: sequence,
            taktRange: [0, 10],
            syncPointE: 6.5,
            status: "INITIALIZED",
            timestamp: Date.now()
        };

        this.activeNodes.push(newSpace);
        
        // Update für die browser.html Kacheln
        this.updateFrontendInterface(sequence);
        
        return newSpace;
    }

    /**
     * Triggert die visuelle Kachel-Erweiterung im Monster-Scaling-Modul
     */
    updateFrontendInterface(sequence) {
        // Simulierter DOM-Push an die scaling-row in browser.html
        console.log(`[INTERFACE] Kachel ${sequence} in Echtzeit-Ansicht injiziert.`);
    }

    /**
     * Überwacht den Takt 10 Übergang
     */
    monitorTransition(currentSequence, currentTakt) {
        if (currentTakt >= 10) {
            const next = this.generateNextSequence(currentSequence);
            this.currentSequence = next;
            return this.spawnNewTaktRoom(next);
        }
        return null;
    }
}

// Initialisierung der Scaling-Engine
const scalingEngine = new MonsterScaling();

// Beispiel: Simulation des Übergangs von Z10 zu AA0
// let nextNode = scalingEngine.monitorTransition("Z", 10);
// console.log("Nächster Takt-Raum:", nextNode.id); // Output: AA
