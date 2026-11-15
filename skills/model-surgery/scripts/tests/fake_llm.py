"""A stand-in for ollama (/api/generate) and llama-server (/completion). Model 'good' answers and stops; 'loopy' repeats a phrase to the token limit;
'empty' returns nothing; 'same' = 'good'. Prints its port on the first line. Greedy and deterministic, like the real ones with temperature 0."""
import json, sys
from http.server import BaseHTTPRequestHandler, HTTPServer


class H(BaseHTTPRequestHandler):
    def do_POST(self):
        n = int(self.headers.get("content-length") or 0)
        req = json.loads(self.rfile.read(n))
        model = req.get("model", "good")
        prompt = req["prompt"]
        if model == "loopy":
            text, stopped = "the proof is trivial " * 30, False
        elif model == "empty":
            text, stopped = "", True
        else:
            text, stopped = "answer: " + prompt.upper(), True
        if self.path == "/api/generate":
            out = {"response": text, "done_reason": "stop" if stopped else "length", "eval_count": len(text.split())}
        elif self.path == "/completion":
            out = {"content": text, "stop_type": "eos" if stopped else "limit", "tokens_predicted": len(text.split())}
        else:
            self.send_response(404); self.end_headers(); return
        b = json.dumps(out).encode()
        self.send_response(200); self.send_header("content-type", "application/json"); self.send_header("content-length", str(len(b))); self.end_headers(); self.wfile.write(b)

    def log_message(self, *a):
        pass


srv = HTTPServer(("127.0.0.1", 0), H)
print(srv.server_port, flush=True)
srv.serve_forever()
