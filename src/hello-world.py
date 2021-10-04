from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import logging

class Server(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        return

    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_HEAD(self):
        self._set_headers()

    # GET sends back a Hello world message
    def do_GET(self):
        self._set_headers()
        if self.path == '/health':
            self.wfile.write(json.dumps({'status': 'ok'}).encode('utf-8'))
        else:
            self.wfile.write(json.dumps({'this_space_intentionally_left': 'blank'}).encode('utf-8'))

        # combined log format
        logging.info("%s - - [%s] \"%s %s %s\" 200 - \"%s\" \"%s\"",
                     str(self.client_address[0]),
                     str(self.log_date_time_string()),
                     str(self.command),
                     str(self.path),
                     str(self.request_version),
                     str(self.headers.get('referrer', "")),
                     str(self.headers.get('user-agent',"")))


    def do_POST(self):
        # refuse all POSTs.  I could see an argument for this being either a
        # 400 or a 403, honestly
        self.send_response(403)
        # combined log format
        logging.info("%s - - [%s] \"%s %s %s\" 403 - \"%s\" \"%s\"",
                     str(self.client_address[0]),
                     str(self.log_date_time_string()),
                     str(self.command),
                     str(self.path),
                     str(self.request_version),
                     str(self.headers.get('referrer', "")),
                     str(self.headers.get('user-agent',"")))

def run(server_class=HTTPServer, handler_class=Server, port=3000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    logging.basicConfig(format='%(message)s', level=logging.INFO)

    logging.info('Starting httpd on port %d...', port)
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
