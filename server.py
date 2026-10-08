"""
EcoTrack Backend Server
Serves static web frontend and trip telemetry APIs on ports 3000 and 3001.
"""

import http.server
import json
import os
import sys
import threading
import time

BASE_DIR = os.path.dirname(__file__)

class EcoTrackHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        if self.path == "/api/v1/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "OK", "service": "EcoTrack"}).encode('utf-8'))
            return

        super().do_GET()

    def do_POST(self):
        if self.path == "/api/v1/trips/save":
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length).decode('utf-8')
            try:
                body = json.loads(post_data) if post_data else {}
            except Exception:
                body = {}
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "SUCCESS", "message": "Trip recorded", "received": body}).encode('utf-8'))
            return

        self.send_response(404)
        self.end_headers()

def start_server(port):
    httpd = http.server.ThreadingHTTPServer(('', port), EcoTrackHandler)
    print(f"EcoTrack listening on http://localhost:{port}")
    httpd.serve_forever()

if __name__ == "__main__":
    t1 = threading.Thread(target=start_server, args=(3000,), daemon=True)
    t1.start()
    start_server(3001)
