#!/usr/bin/env python3
"""Serve ONE folder on 127.0.0.1 with CORS, for the upload workaround in references/publish-route.md.

Usage: serve-folder.py FOLDER [PORT]      (default port 8765; run in the background; stop it afterwards)
Binds to 127.0.0.1 only. Serves only files inside FOLDER. Put COPIES of the files there.
"""
import http.server, os, sys, functools


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, *a):
        pass


def main():
    if len(sys.argv) < 2 or not os.path.isdir(sys.argv[1]):
        sys.exit(__doc__)
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8765
    handler = functools.partial(Handler, directory=os.path.abspath(sys.argv[1]))
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", port), handler)
    print("serving %s on http://127.0.0.1:%d (Ctrl-C or kill to stop)" % (sys.argv[1], port), flush=True)
    srv.serve_forever()


if __name__ == "__main__":
    main()
