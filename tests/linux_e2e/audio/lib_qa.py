"""Helpers for the SoftphonePro audio QA (runs on the Mac host, drives the qa-audio-* containers via docker exec).

Env: DOCKER_CONFIG / DOCKER_HOST must be set as in the QA brief. Containers mount this directory at /e2e.
"""
import json, os, subprocess, time

TOKEN = "ab" * 32
PORT = 7771
HOSTDIR = os.path.dirname(os.path.abspath(__file__))


def dx(name, cmd, user="qa", check=False, timeout=120, env=None):
    args = ["docker", "exec", "-u", user]
    env = dict({"XDG_RUNTIME_DIR": "/tmp/xdg-qa", "DISPLAY": ":99"}, **(env or {}))
    for k, v in env.items():
        args += ["-e", f"{k}={v}"]
    args += [name, "bash", "-lc", cmd]
    r = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
    if check and r.returncode:
        raise RuntimeError(f"{cmd} -> {r.returncode}: {r.stderr[:300]}")
    return (r.stdout + (("\n[stderr] " + r.stderr) if r.stderr.strip() and not check else "")).strip()


def api(name, method, path, body=None, raw=False):
    cmd = f"curl -sS -m 8 -X {method} -H 'Authorization: Bearer {TOKEN}' -H 'Content-Type: application/json' "
    if body is not None:
        cmd += "-d '" + json.dumps(body) + "' "
    cmd += f"http://127.0.0.1:{PORT}{path}"
    r = subprocess.run(["docker", "exec", "-u", "qa", name, "bash", "-c", cmd], capture_output=True, text=True, timeout=30)
    if raw:
        return r.stdout
    try:
        return json.loads(r.stdout or "{}")
    except Exception:
        return {"_raw": r.stdout, "_err": r.stderr}


def provision(name, user, pw, settings=None, extra_accounts=None):
    s = {"automationEnabled": True, "automationPort": PORT, "automationToken": TOKEN, "stunServers": [], "dnd": False}
    s.update(settings or {})
    cfg = {"accounts": [{"username": user, "password": pw, "domain": "172.30.0.10", "transport": "udp", "label": user}],
           "settings": s}
    path = os.path.join(HOSTDIR, "out", f"{name}-provision.json")
    json.dump(cfg, open(path, "w"))
    os.chmod(path, 0o666)
    return f"/e2e/out/{name}-provision.json"


def boot(name, prov, lang="C.UTF-8"):
    dx(name, f"mkdir -p /e2e/out/{name} && /e2e/node_boot.sh {prov} /e2e/out/{name} {lang}")
    for _ in range(90):
        st = api(name, "GET", "/v1/status")
        if st.get("app"):
            return st
        time.sleep(1)
    raise RuntimeError("API did not come up on " + name)


def kill_app(name):
    dx(name, "pkill -x softphonepro; sleep 1; pkill -9 -x softphonepro; true")
    time.sleep(1)


def restart_app(name, prov=None, lang="C.UTF-8"):
    kill_app(name)
    dx(name, f"/e2e/app_start.sh '{prov or ''}' /e2e/out/{name} {lang}")
    for _ in range(90):
        if api(name, "GET", "/v1/status").get("app"):
            return
        time.sleep(1)
    raise RuntimeError("no API after restart")


def wait(fn, timeout=20, step=0.5):
    end = time.time() + timeout
    while time.time() < end:
        try:
            v = fn()
            if v:
                return v
        except Exception:
            pass
        time.sleep(step)
    return None


def registered(name):
    st = api(name, "GET", "/v1/status")
    return bool(st.get("accounts")) and st["accounts"][0]["regState"] == "registered"


def shot(name, fname):
    """Screenshot the X root of container `name` to /e2e/out/<fname> (host: out/<fname>)."""
    dx(name, f"DISPLAY=:99 import -window root /e2e/out/{fname}")
    return os.path.join(HOSTDIR, "out", fname)


def tone_levels(name, wav, freqs, t0=None, t1=None, chan=None):
    """dBFS (RMS) of each freq in [t0,t1] of channel chan (0=left,1=right,None=mix) of `wav` inside container."""
    a = f"python3 /e2e/tone.py {wav} {t0 if t0 is not None else -1} {t1 if t1 is not None else -1} {chan if chan is not None else -1} " + " ".join(map(str, freqs))
    return json.loads(dx(name, a))
