/**
 * PZQQET SYSTEM-ARCHITEKTUR: EDITION 4.0
 * SEKTOR: ADMIN-CONTROL
 * MODUL: SYSTEM-MONITOR (KACHEL-VISUALISIERUNG)
 */

import time
import json

class SystemMonitor:
    def __init__(self):
        self.total_tiles = 13
        self.master_id = "@RFOF-NETWORK"
        self.axiom = "100.000.000%"
        
        # Initialisierung der 13 dualen Kacheln (Genesis vs. Sync)
        self.tile_states = {i: {"genesis": "IDLE", "sync": "IDLE", "offset": 0.0} for i in range(1, 14)}

    def update_tile_status(self, tile_id, genesis_val, sync_val):
        """
        Aktualisiert den Status einer spezifischen Kachel.
        Genesis (R0) muss immer dem Sync (R1) entsprechen.
        """
        if 1 <= tile_id <= self.total_tiles:
            self.tile_states[tile_id]["genesis"] = genesis_val
            self.tile_states[tile_id]["sync"] = sync_val
            
            # Berechnung der Divergenz (muss für 100M% gegen 0 laufen)
            self.tile_states[tile_id]["offset"] = 0.0 if genesis_val == sync_val else 1.0
            
            self.render_dashboard()

    def render_dashboard(self):
        """
        Gibt eine CLI-Visualisierung der 13 dualen Kacheln aus.
        """
        print("\n" + "="*50)
        print(f"PZQQET SYSTEM MONITOR - MASTER: {self.master_id}")
        print(f"INTEGRITY STATUS: {self.axiom}")
        print("="*50)
        
        for tile, data in self.tile_states.items():
            status_icon = "✅" if data["offset"] == 0.0 else "⚠️"
            print(f"TILE {tile:02d}: [GENESIS: {data['genesis']}] <---> [SYNC: {data['sync']}] {status_icon}")
        
        print("="*50)
        print(f"LAST REFRESH: {time.strftime('%H:%M:%S')}")

    def run_telemetry(self):
        """
        Simuliert den kontinuierlichen Datenstrom der Alpha-Nodes.
        """
        print("[MONITOR] Telemetrie-Stream gestartet...")
        # Beispielhafter Sync-Lauf
        for i in range(1, 14):
            time.sleep(0.1) # Takt-Simulation
            self.update_tile_status(i, "ACTIVE", "ACTIVE")

# --- ADMIN START ---
monitor = SystemMonitor()
# monitor.run_telemetry()
