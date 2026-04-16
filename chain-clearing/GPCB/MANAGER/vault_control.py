import os
import json
import time
from datetime import datetime

class VaultControl:
    def __init__(self):
        self.sector = "GPCB"
        self.master_id = "@RFOF-NETWORK"
        self.config_path = "/chain-clearing/GPCB/MANAGER/identity.gt"
        self.vault_path = "/chain-clearing/GPCB/"
        self.is_locked = False

    def check_integrity(self, reality_0_hash, reality_1_hash):
        """
        Vergleicht den Innovations-Code (R0) mit der Exekutions-Leistung (R1).
        Bei Diskrepanzen greift das Mechatronische Sperr-Protokoll.
        """
        print(f"[{self.sector}] Integritäts-Check: R0 vs R1...")
        
        if reality_0_hash != reality_1_hash:
            self.initiate_emergency_lock("DISCREPANCY_DETECTED")
            return False
        
        print(f"[{self.sector}] Synchronisation stabil. 100M% Integrität gewahrt.")
        return True

    def initiate_emergency_lock(self, reason):
        """
        Setzt sofortige Sperren im Verzeichnis und schaltet den Sektor ab.
        """
        self.is_locked = True
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        lock_message = {
            "alert": "CRITICAL_SECTOR_LOCKDOWN",
            "sector": self.sector,
            "reason": reason,
            "timestamp": timestamp,
            "action": "READ_ONLY_MODE_ACTIVATED"
        }

        # Master-Informations-Injektion
        self.inform_master(lock_message)

        # Mechatronische Sperre: Schreibrechte im Verzeichnis entziehen
        try:
            # Simulation einer Verzeichnis-Sperre auf Dateisystem-Ebene
            os.chmod(self.vault_path, 0o555) 
            print(f"[{self.sector}] VERZEICHNIS-SPERRE AKTIVIERT (chmod 555).")
        except Exception as e:
            print(f"FEHLER beim Setzen der Sperre: {e}")

    def inform_master(self, report):
        """
        Sendet den Bericht direkt an die Master-ID @RFOF-NETWORK.
        In der PZQQET-Architektur ist dies der höchste Alarm-Vektor.
        """
        # Injektion in den Master-Event-Vektor
        print(f"!!! ALARM AN {self.master_id} GESENDET !!!")
        print(json.dumps(report, indent=4))

    def unlock_sector(self, master_key):
        """
        Nur der Master kann den Sektor nach einer Sperre wieder freigeben.
        """
        if master_key == "PZQQET_MASTER_OVERRIDE_42E0":
            os.chmod(self.vault_path, 0o775)
            self.is_locked = False
            print(f"[{self.sector}] Sektor durch Master freigegeben.")
        else:
            print("ZUGRIFF VERWEIGERT: Ungültiger Master-Key.")

# --- Instanziierung & Test-Szenario ---
if __name__ == "__main__":
    vault = VaultControl()
    
    # Simulation: Code sagt 100 Einheiten (R0), System führt 101 Einheiten aus (R1)
    reality_0 = "HASH_VAL_100"
    reality_1 = "HASH_VAL_101" 
    
    vault.check_integrity(reality_0, reality_1)
