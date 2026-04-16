import json
import os
import time

class NewsPublisher:
    def __init__(self):
        self.archive_path = "/chain-clearing/STORY-HISTORY/ARCHIVE/"
        self.news_feed_target = "/chain-clearing/browser.html"
        self.active_takts = [7, 8, 9] # Die News-Trigger-Zone
        
    def fetch_news_from_archive(self, takt):
        """
        Greift auf das ARCHIVE-Verzeichnis zu, um die Fortschritts-News
        für den spezifischen Takt zu laden.
        """
        archive_file = f"{self.archive_path}news_takt_{takt}.json"
        
        if os.path.exists(archive_file):
            with open(archive_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data.get("content", "Keine News-Details gefunden.")
        else:
            # Fallback, falls die spezifische Archiv-Datei noch leer ist
            return f"Innovation im Takt {takt} erfolgreich verarbeitet."

    def render_to_browser(self, takt):
        """
        Simuliert das Rendern der Nachricht in den Newsfeed der browser.html.
        In der mechatronischen Kopplung erfolgt dies via DOM-Injektion oder WebSocket.
        """
        if takt in self.active_takts:
            news_content = self.fetch_news_from_archive(takt)
            print(f"[GT-PUBLISHER] Takt {takt} erkannt!")
            print(f"[NEWSFEED-INJEKTION]: {news_content}")
            
            # Hier würde der binäre Call an das Frontend erfolgen
            self._update_frontend_feed(takt, news_content)
        else:
            print(f"[PUBLISHER] Takt {takt} ist außerhalb der News-Trigger-Zone.")

    def _update_frontend_feed(self, takt, content):
        """
        Fixiert die Nachricht als notarisiertes Ereignis.
        """
        event = {
            "type": "GT_NEWS_UPDATE",
            "takt": takt,
            "content": content,
            "status": "NOTARIZED"
        }
        # Diese Daten werden vom 'news-feed' Element in browser.html abgegriffen
        return json.dumps(event)

# --- Instanziierung ---
publisher = NewsPublisher()

# Beispiel: Wenn der Takt-Generator Takt 8 erreicht
# publisher.render_to_browser(8)
