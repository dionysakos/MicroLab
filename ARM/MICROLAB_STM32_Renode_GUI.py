#!/usr/bin/env python3
"""
Renode GPIO + UART + Monitor Console GUI.

Start Renode:
    renode -P 1234

Run:
    python3 renode_gpio_uart_console_gui_v2.py

Open:
    http://127.0.0.1:8088
"""

import argparse
import json
import re
import socket
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

GPIO_PORTS = {
    "A": {
        "base": 0x40020000,
        "object": "sysbus.gpioPortA",
        "label": "GPIOA",
    },
    "D": {
        "base": 0x40020C00,
        "object": "sysbus.gpioPortD",
        "label": "GPIOD",
    },
}

IDR_OFFSET = 0x10
ODR_OFFSET = 0x14

DEFAULT_ODR_POLL_MS = 5.0
DEFAULT_IDR_POLL_MS = 50.0
DEFAULT_UART_PORT = 54321

HTML = r"""<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>MICROLAB STM32-Renode GUI</title>
  <style>
    :root {
      --bg: #f6f7f9;
      --card: #ffffff;
      --line: #dce2ea;
      --text: #172033;
      --muted: #637084;
      --good: #25d366;
      --blue: #57a6ff;
      --bad-bg: #ffe8e8;
      --bad-text: #8b1d1d;
      --ok-bg: #e4f8ea;
      --ok-text: #136c2f;
    }
    body {
      font-family: system-ui, -apple-system, Segoe UI, sans-serif;
      background: var(--bg);
      color: var(--text);
      margin: 18px;
    }
    h1 { margin: 0 0 6px 0; }
    h2 { margin: 0 0 10px 0; font-size: 18px; }
    .sub { color: var(--muted); margin-bottom: 14px; }
    .status {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 999px;
      background: #eef0f4;
      font-size: 12px;
      margin-left: 8px;
    }
    .ok { background: var(--ok-bg); color: var(--ok-text); }
    .bad { background: var(--bad-bg); color: var(--bad-text); }
    .layout {
      display: grid;
      grid-template-columns: minmax(720px, 1.2fr) minmax(420px, 0.8fr);
      gap: 14px;
      align-items: start;
    }
    @media (max-width: 1200px) {
      .layout { grid-template-columns: 1fr; }
    }
    .card {
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: 16px;
      padding: 14px;
      margin-bottom: 14px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }
    .port-title {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: 8px;
    }
    .regs {
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      color: #455065;
      font-size: 12px;
      margin-bottom: 8px;
    }
    .grid {
      display: grid;
      grid-template-columns: 42px repeat(16, minmax(34px, 1fr));
      gap: 4px;
      align-items: center;
      overflow-x: auto;
    }
    .label {
      text-align: right;
      color: var(--muted);
      font-size: 12px;
      padding-right: 4px;
    }
    .pin {
      text-align: center;
      color: var(--muted);
      font-size: 11px;
      font-weight: 600;
    }
    .led, .dot {
      width: 20px;
      height: 20px;
      border-radius: 50%;
      margin: 4px auto;
      border: 2px solid #687386;
      background: #222832;
      box-shadow: inset 0 1px 2px rgba(0,0,0,0.35);
    }
    .led.on {
      background: var(--good);
      border-color: #149345;
      box-shadow: 0 0 12px rgba(37,211,102,0.85);
    }
    .dot {
      width: 16px;
      height: 16px;
      background: #c7cfdb;
    }
    .dot.on {
      background: var(--blue);
      border-color: #2678cf;
      box-shadow: 0 0 10px rgba(87,166,255,0.85);
    }
    button {
      border: 1px solid #bac3d0;
      background: #fff;
      padding: 6px 9px;
      border-radius: 9px;
      cursor: pointer;
      font-size: 12px;
      margin: 2px;
    }
    button:hover { background: #eef3fb; }
    button:active { transform: translateY(1px); }
    .smallbtn {
      font-size: 10px;
      padding: 2px 3px;
      width: 100%;
      min-width: 30px;
      margin: 0;
    }
    textarea, input {
      width: 100%;
      box-sizing: border-box;
      border: 1px solid #bac3d0;
      border-radius: 10px;
      padding: 8px;
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      font-size: 13px;
      background: #fbfcfe;
    }
    .console, .uart {
      background: #101722;
      color: #d7e2f0;
      border-radius: 12px;
      padding: 10px;
      height: 270px;
      overflow: auto;
      white-space: pre-wrap;
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      font-size: 12px;
      border: 1px solid #0b1018;
    }
    .row {
      display: flex;
      gap: 8px;
      align-items: center;
      flex-wrap: wrap;
      margin: 8px 0;
    }
    .grow { flex: 1 1 auto; }
    .hint {
      color: var(--muted);
      font-size: 13px;
      line-height: 1.45;
    }
    code {
      background: #eef0f4;
      padding: 1px 4px;
      border-radius: 4px;
    }
  </style>
</head>
<body>
  <h1>MICROLAB STM32-Renode GUI <span id="status" class="status">connecting...</span></h1>
  <div class="sub">
    Full GPIOA/GPIOD. No MODER polling. ODR fast-poll, IDR slower-poll, optimistic button feedback.
  </div>

  <div class="layout">
    <div>
      <div id="ports"></div>
    </div>

    <div>
      <div class="card">
        <h2>Renode Monitor Console</h2>
        <div class="hint">
          Paste commands here instead of using telnet. Multi-line commands are executed one line at a time.
        </div>
        <textarea id="cmd" rows="7" spellcheck="false">mach create
machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl
sysbus LoadELF @/absolute/path/to/your_project.elf
machine StartGdbServer 3333
start</textarea>
        <div class="row">
          <button onclick="sendCmd()">Send command(s)</button>
          <button onclick="quick('start')">start</button>
          <button onclick="quick('pause')">pause</button>
          <button onclick="quick('machine Reset')">machine Reset</button>
          <button onclick="clearConsole()">clear output</button>
        </div>
        <div id="console" class="console"></div>
      </div>

      <div class="card">
        <h2>UART2 Monitor</h2>
        <div class="hint">
          Click Attach UART2 after the platform is loaded.
        </div>
        <div class="row">
          <button onclick="attachUart()">Attach UART2</button>
          <button onclick="clearUart()">clear UART</button>
        </div>
        <div id="uart" class="uart"></div>
        <div class="row">
          <input id="uart_tx" class="grow" placeholder="Text to send to virtual UART RX">
          <button onclick="sendUart()">Send</button>
        </div>
      </div>
    </div>
  </div>

<script>
const REFRESH_MS = 10;
let inFlight = false;
const optimisticIDR = {A: 0, D: 0};

function hex(v, digits=8) {
  if (v === null || v === undefined) return "----";
  return "0x" + Number(v).toString(16).toUpperCase().padStart(digits, "0");
}

function makePorts() {
  const root = document.getElementById("ports");
  root.innerHTML = "";
  for (const p of ["A","D"]) {
    const div = document.createElement("div");
    div.className = "card";
    div.innerHTML = `
      <div class="port-title">
        <h2>GPIO${p}</h2>
        <div class="regs" id="regs_${p}">IDR=---- ODR=----</div>
      </div>
      <div class="grid">
        <div></div>
        ${[...Array(16)].map((_,i) => `<div class="pin">${15-i}</div>`).join("")}
        <div class="label">ODR</div>
        ${[...Array(16)].map((_,i) => `<div class="led" id="odr_${p}_${15-i}" title="GPIO${p}${15-i} output latch"></div>`).join("")}
        <div class="label">IDR</div>
        ${[...Array(16)].map((_,i) => `<div class="dot" id="idr_${p}_${15-i}" title="GPIO${p}${15-i} input level"></div>`).join("")}
        <div class="label">hold</div>
        ${[...Array(16)].map((_,i) => {
          const pin = 15-i;
          return `<button class="smallbtn"
            onmousedown="gpio('${p}',${pin},1)"
            onmouseup="gpio('${p}',${pin},0)"
            onmouseleave="gpio('${p}',${pin},0)"
            ontouchstart="gpio('${p}',${pin},1)"
            ontouchend="gpio('${p}',${pin},0)">hold</button>`;
        }).join("")}
        <div class="label">1</div>
        ${[...Array(16)].map((_,i) => `<button class="smallbtn" onclick="gpio('${p}',${15-i},1)">1</button>`).join("")}
        <div class="label">0</div>
        ${[...Array(16)].map((_,i) => `<button class="smallbtn" onclick="gpio('${p}',${15-i},0)">0</button>`).join("")}
        <div class="label">pulse</div>
        ${[...Array(16)].map((_,i) => `<button class="smallbtn" onclick="pulse('${p}',${15-i})">p</button>`).join("")}
      </div>
    `;
    root.appendChild(div);
  }
}

function setOn(id, on) {
  const e = document.getElementById(id);
  if (e) e.classList.toggle("on", !!on);
}

function paintPort(p, st) {
  let idr = st.idr | optimisticIDR[p];
  const odr = st.odr;

  document.getElementById(`regs_${p}`).textContent =
    `IDR=${hex(idr)} ODR=${hex(odr)}`;

  for (let pin = 0; pin < 16; pin++) {
    setOn(`odr_${p}_${pin}`, odr & (1 << pin));
    setOn(`idr_${p}_${pin}`, idr & (1 << pin));
  }
}

async function refresh() {
  if (inFlight) return;
  inFlight = true;
  try {
    const r = await fetch("/api/state", {cache: "no-store"});
    const s = await r.json();

    const status = document.getElementById("status");
    if (!s.ok) {
      status.className = "status bad";
      status.textContent = s.error || "error";
      return;
    }

    status.className = "status ok";
    status.textContent = `connected, ODR ${s.odr_poll_ms.toFixed(1)} ms, IDR ${s.idr_poll_ms.toFixed(1)} ms`;

    for (const p of ["A","D"]) {
      paintPort(p, s.ports[p]);
    }

    updateUart(s.uart || "");
  } catch (e) {
    const status = document.getElementById("status");
    status.className = "status bad";
    status.textContent = "not connected";
  } finally {
    inFlight = false;
  }
}

function setOptimistic(port, pin, value) {
  if (value) {
    optimisticIDR[port] |= (1 << pin);
  } else {
    optimisticIDR[port] &= ~(1 << pin);
  }
  const dot = document.getElementById(`idr_${port}_${pin}`);
  if (dot) dot.classList.toggle("on", !!value);
}

function gpio(port, pin, value) {
  setOptimistic(port, pin, value);

  // Fire and forget for snappy UI. The backend also updates its cache immediately.
  fetch(`/api/gpio/${port}/${pin}/${value ? 1 : 0}`, {method: "POST", cache: "no-store"})
    .then(() => {
      setTimeout(refresh, 1);
      setTimeout(refresh, 10);
      setTimeout(refresh, 30);
    })
    .catch(() => {});
}

async function pulse(port, pin) {
  gpio(port, pin, 1);
  setTimeout(() => gpio(port, pin, 0), 50);
}

function appendConsole(text) {
  const e = document.getElementById("console");
  e.textContent += text;
  e.scrollTop = e.scrollHeight;
}

async function sendCmdText(text) {
  const r = await fetch("/api/command", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({cmd: text})
  });
  const j = await r.json();
  appendConsole(j.output || j.error || "");
  refresh();
}

async function sendCmd() {
  const t = document.getElementById("cmd").value;
  appendConsole(`\n>>> ${t}\n`);
  await sendCmdText(t);
}

async function quick(cmd) {
  appendConsole(`\n>>> ${cmd}\n`);
  await sendCmdText(cmd);
}

function clearConsole() {
  document.getElementById("console").textContent = "";
}

async function attachUart() {
  appendConsole("\n>>> attach UART2\n");
  const r = await fetch("/api/uart/attach", {method: "POST"});
  const j = await r.json();
  appendConsole(j.output || j.error || "");
  refresh();
}

function clearUart() {
  fetch("/api/uart/clear", {method: "POST"});
  document.getElementById("uart").textContent = "";
}

async function sendUart() {
  const inp = document.getElementById("uart_tx");
  const text = inp.value;
  inp.value = "";
  await fetch("/api/uart/send", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({text})
  });
}

function updateUart(text) {
  const e = document.getElementById("uart");
  if (e.textContent !== text) {
    e.textContent = text;
    e.scrollTop = e.scrollHeight;
  }
}

makePorts();
refresh();
setInterval(refresh, REFRESH_MS);
</script>
</body>
</html>
"""

class RenodeMonitor:
    def __init__(self, host, port, timeout=0.45):
        self.host = host
        self.port = port
        self.timeout = timeout
        self.sock = None
        self.lock = threading.Lock()

    def connect(self):
        if self.sock is not None:
            return
        s = socket.create_connection((self.host, self.port), timeout=self.timeout)
        s.settimeout(self.timeout)
        self.sock = s
        time.sleep(0.03)
        try:
            s.recv(65536)
        except socket.timeout:
            pass

    def close(self):
        try:
            if self.sock:
                self.sock.close()
        finally:
            self.sock = None

    def command(self, cmd):
        with self.lock:
            try:
                self.connect()
                self.sock.sendall((cmd + "\n").encode("utf-8"))
                out = b""
                deadline = time.time() + self.timeout
                while time.time() < deadline:
                    try:
                        chunk = self.sock.recv(65536)
                    except socket.timeout:
                        break
                    if not chunk:
                        break
                    out += chunk
                    if re.search(rb"\([^)]+\)\s*$", out):
                        break
                return out.decode("utf-8", errors="replace")
            except Exception:
                self.close()
                raise

    def read_dword(self, addr):
        out = self.command(f"sysbus ReadDoubleWord 0x{addr:08X}")
        matches = re.findall(r"0x[0-9a-fA-F]+", out)
        if not matches:
            raise RuntimeError(f"could not parse read of 0x{addr:08X}: {out!r}")
        return int(matches[-1], 16)

class UartSocketReader:
    def __init__(self, host="127.0.0.1", port=DEFAULT_UART_PORT, max_chars=40000):
        self.host = host
        self.port = port
        self.max_chars = max_chars
        self.lock = threading.Lock()
        self.text = ""
        self.sock = None
        self.thread = None
        self.stop_event = threading.Event()

    def start(self):
        if self.thread and self.thread.is_alive():
            return
        self.stop_event.clear()
        self.thread = threading.Thread(target=self._run, daemon=True)
        self.thread.start()

    def _append(self, s):
        with self.lock:
            self.text += s
            if len(self.text) > self.max_chars:
                self.text = self.text[-self.max_chars:]

    def _run(self):
        while not self.stop_event.is_set():
            try:
                s = socket.create_connection((self.host, self.port), timeout=1.0)
                s.settimeout(0.2)
                self.sock = s
                self._append(f"\n[UART socket connected on {self.host}:{self.port}]\n")
                while not self.stop_event.is_set():
                    try:
                        data = s.recv(4096)
                        if not data:
                            break
                        cleaned = bytearray()
                        i = 0
                        while i < len(data):
                            if data[i] == 0xFF and i + 2 < len(data):
                                i += 3
                            else:
                                cleaned.append(data[i])
                                i += 1
                        if cleaned:
                            self._append(cleaned.decode("utf-8", errors="replace"))
                    except socket.timeout:
                        continue
                try:
                    s.close()
                except Exception:
                    pass
                self.sock = None
            except Exception:
                time.sleep(0.5)

    def send(self, text):
        if self.sock is not None:
            self.sock.sendall(text.encode("utf-8"))

    def snapshot(self):
        with self.lock:
            return self.text

    def clear(self):
        with self.lock:
            self.text = ""

class CachedState:
    def __init__(self):
        self.lock = threading.Lock()
        self.ports = {
            "A": {"idr": 0, "odr": 0},
            "D": {"idr": 0, "odr": 0},
        }
        self.ok = False
        self.error = "not polled yet"
        self.odr_poll_ms = 0.0
        self.idr_poll_ms = 0.0

    def update_odr(self, port, odr, poll_ms):
        with self.lock:
            self.ports[port]["odr"] = odr & 0xFFFFFFFF
            self.ok = True
            self.error = ""
            self.odr_poll_ms = poll_ms

    def update_idr(self, port, idr, poll_ms):
        with self.lock:
            self.ports[port]["idr"] = idr & 0xFFFFFFFF
            self.ok = True
            self.error = ""
            self.idr_poll_ms = poll_ms

    def set_input_bit_optimistic(self, port, pin, value):
        with self.lock:
            if value:
                self.ports[port]["idr"] |= (1 << pin)
            else:
                self.ports[port]["idr"] &= ~(1 << pin)

    def update_error(self, error):
        with self.lock:
            self.ok = False
            self.error = str(error)

    def snapshot(self):
        with self.lock:
            return {
                "ok": self.ok,
                "error": self.error,
                "ports": {p: dict(v) for p, v in self.ports.items()},
                "odr_poll_ms": self.odr_poll_ms,
                "idr_poll_ms": self.idr_poll_ms,
            }

class SplitPoller(threading.Thread):
    def __init__(self, monitor, state, odr_interval_s, idr_interval_s):
        super().__init__(daemon=True)
        self.monitor = monitor
        self.state = state
        self.odr_interval_s = odr_interval_s
        self.idr_interval_s = idr_interval_s
        self.stop_event = threading.Event()

    def run(self):
        next_odr = time.perf_counter()
        next_idr = time.perf_counter()
        while not self.stop_event.is_set():
            now = time.perf_counter()

            if now >= next_odr:
                t0 = time.perf_counter()
                try:
                    for p, cfg in GPIO_PORTS.items():
                        odr = self.monitor.read_dword(cfg["base"] + ODR_OFFSET)
                        self.state.update_odr(p, odr, (time.perf_counter() - t0) * 1000.0)
                except Exception as e:
                    self.state.update_error(e)
                next_odr = now + self.odr_interval_s

            if now >= next_idr:
                t0 = time.perf_counter()
                try:
                    for p, cfg in GPIO_PORTS.items():
                        idr = self.monitor.read_dword(cfg["base"] + IDR_OFFSET)
                        self.state.update_idr(p, idr, (time.perf_counter() - t0) * 1000.0)
                except Exception as e:
                    self.state.update_error(e)
                next_idr = now + self.idr_interval_s

            next_time = min(next_odr, next_idr)
            sleep_for = max(0.001, next_time - time.perf_counter())
            self.stop_event.wait(sleep_for)

class Handler(BaseHTTPRequestHandler):
    monitor = None
    state = None
    uart = None
    uart_port = DEFAULT_UART_PORT

    def log_message(self, fmt, *args):
        return

    def _json(self, obj, code=200):
        body = json.dumps(obj).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def _html(self):
        body = HTML.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self):
        n = int(self.headers.get("Content-Length", 0))
        if n <= 0:
            return {}
        return json.loads(self.rfile.read(n).decode("utf-8"))

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/":
            self._html()
        elif path == "/api/state":
            s = self.state.snapshot()
            s["uart"] = self.uart.snapshot()
            self._json(s)
        else:
            self.send_error(404)

    def do_POST(self):
        path = urlparse(self.path).path

        m = re.fullmatch(r"/api/gpio/([AD])/([0-9]|1[0-5])/([01])", path)
        if m:
            port, pin_s, value_s = m.groups()
            pin = int(pin_s)
            value = value_s == "1"
            obj = GPIO_PORTS[port]["object"]
            cmd = f"{obj} OnGPIO {pin} {'true' if value else 'false'}"
            self.state.set_input_bit_optimistic(port, pin, value)
            try:
                out = self.monitor.command(cmd)
                self._json({"ok": True, "cmd": cmd, "output": out})
            except Exception as e:
                self._json({"ok": False, "cmd": cmd, "error": str(e)}, 500)
            return

        if path == "/api/command":
            try:
                body = self._read_json()
                text = body.get("cmd", "")
                output = ""
                for line in text.splitlines():
                    cmd = line.strip()
                    if not cmd:
                        continue
                    try:
                        out = self.monitor.command(cmd)
                        output += f"\n>>> {cmd}\n{out}"
                    except Exception as e:
                        output += f"\n>>> {cmd}\nERROR: {e}\n"
                self._json({"ok": True, "output": output})
            except Exception as e:
                self._json({"ok": False, "error": str(e)}, 500)
            return

        if path == "/api/uart/attach":
            try:
                out = ""
                for cmd in [
                    f'emulation CreateServerSocketTerminal {self.uart_port} "uart_gui" false',
                    "connector Connect sysbus.usart2 uart_gui",
                ]:
                    try:
                        out += f"\n>>> {cmd}\n{self.monitor.command(cmd)}"
                    except Exception as e:
                        out += f"\n>>> {cmd}\nERROR: {e}\n"
                self.uart.start()
                self._json({"ok": True, "output": out + f"\n[Python GUI connecting to UART socket {self.uart_port}]\n"})
            except Exception as e:
                self._json({"ok": False, "error": str(e)}, 500)
            return

        if path == "/api/uart/clear":
            self.uart.clear()
            self._json({"ok": True})
            return

        if path == "/api/uart/send":
            try:
                body = self._read_json()
                text = body.get("text", "")
                self.uart.send(text)
                self._json({"ok": True})
            except Exception as e:
                self._json({"ok": False, "error": str(e)}, 500)
            return

        self.send_error(404)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--renode-host", default="127.0.0.1")
    ap.add_argument("--renode-port", default=1234, type=int)
    ap.add_argument("--web-host", default="127.0.0.1")
    ap.add_argument("--web-port", default=8088, type=int)
    ap.add_argument("--odr-poll-ms", default=DEFAULT_ODR_POLL_MS, type=float, help="ODR output poll interval in ms")
    ap.add_argument("--idr-poll-ms", default=DEFAULT_IDR_POLL_MS, type=float, help="IDR input poll interval in ms")
    ap.add_argument("--uart-port", default=DEFAULT_UART_PORT, type=int, help="UART socket terminal port")
    args = ap.parse_args()

    monitor = RenodeMonitor(args.renode_host, args.renode_port)
    state = CachedState()
    uart = UartSocketReader(args.renode_host, args.uart_port)
    poller = SplitPoller(monitor, state, args.odr_poll_ms / 1000.0, args.idr_poll_ms / 1000.0)

    Handler.monitor = monitor
    Handler.state = state
    Handler.uart = uart
    Handler.uart_port = args.uart_port

    server = ThreadingHTTPServer((args.web_host, args.web_port), Handler)
    poller.start()

    print(f"MICROLAB STM32-Renode GUI: http://{args.web_host}:{args.web_port}")
    print(f"Renode Monitor TCP: {args.renode_host}:{args.renode_port}")
    print(f"UART socket port used by GUI: {args.uart_port}")
    print(f"Polling GPIOA/GPIOD ODR every {args.odr_poll_ms:g} ms.")
    print(f"Polling GPIOA/GPIOD IDR every {args.idr_poll_ms:g} ms.")
    print("MODER is not polled.")
    print("Start Renode with: renode -P 1234")
    print("Press Ctrl+C to stop.")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping.")
    finally:
        poller.stop_event.set()
        server.server_close()
        monitor.close()

if __name__ == "__main__":
    main()
