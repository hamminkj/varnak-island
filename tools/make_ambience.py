"""Lush stereo ambient loops for Tujuju Island, generated from code (no recordings).
Run: python3 tools/make_ambience.py   (needs numpy, scipy and ffmpeg). Writes sfx/amb_*.ogg.
Every loop is seamless: the tail is folded back onto the start."""
import os, subprocess, tempfile, wave
import numpy as np
from scipy.signal import lfilter, butter, fftconvolve

SR = 24000
OUT = os.path.join(os.path.dirname(__file__), "..", "sfx")
rng = np.random.default_rng(2026)

def n(sec): return rng.standard_normal(int(SR * sec))
def tt(sec): return np.arange(int(SR * sec)) / SR
def bp(x, lo, hi, order=2):
    b, a = butter(order, [lo / (SR / 2), hi / (SR / 2)], btype="band"); return lfilter(b, a, x)
def lp(x, hi, order=2):
    b, a = butter(order, hi / (SR / 2), btype="low"); return lfilter(b, a, x)
def hp(x, lo, order=2):
    b, a = butter(order, lo / (SR / 2), btype="high"); return lfilter(b, a, x)
def smooth_env(sec, rate, lo=0.3, hi=1.0):
    k = max(2, int(sec * rate) + 2)
    pts = rng.uniform(lo, hi, k)
    x = np.linspace(0, k - 1, int(SR * sec))
    i = np.floor(x).astype(int); f = x - i; f = f * f * (3 - 2 * f)
    return pts[i] * (1 - f) + pts[np.minimum(i + 1, k - 1)] * f
def place(buf, x, at):
    i = int(at * SR) % len(buf)
    j = i + len(x)
    if j <= len(buf): buf[i:j] += x
    else:
        k = len(buf) - i
        buf[i:] += x[:k]; buf[: j - len(buf)] += x[k:]
def pan_place(L, R, x, at, pan):
    g = np.pi * (pan + 1) / 4
    place(L, x * np.cos(g), at); place(R, x * np.sin(g), at)
def reverb(x, sec, tone=4000, wet=0.3):
    ir = rng.standard_normal(int(SR * sec)) * np.exp(-tt(sec) / (sec / 5))
    ir = lp(ir, tone); ir /= np.sqrt(np.sum(ir ** 2))
    y = fftconvolve(x, ir)[: len(x)]
    # wrap the reverb tail so the loop stays seamless
    tail = fftconvolve(x[-int(SR * sec):], ir)[int(SR * sec):]
    y[: len(tail)] += tail[: len(y)]
    return x * (1 - wet) + y * wet
def wrap(x, tail):
    # fold a generated tail back onto the start
    x[: len(tail)] += tail
    return x
def save(name, L, R, peak=0.7):
    m = max(np.max(np.abs(L)), np.max(np.abs(R))) or 1.0
    st = np.stack([L, R], 1) / m * peak
    pcm = (np.clip(st, -1, 1) * 32767).astype(np.int16)
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f: tmp = f.name
    with wave.open(tmp, "wb") as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", tmp, "-c:a", "libvorbis", "-q:a", "4", os.path.join(OUT, name + ".ogg")], check=True)
    os.remove(tmp)
def loopnoise(sec, f):
    # seamless filtered noise: filter a longer run, keep the middle, crossfade the ends
    x = f(n(sec + 2.0))[int(SR):int(SR) + int(SR * sec) + int(SR * 0.5)]
    body = x[: int(SR * sec)].copy(); tail = x[int(SR * sec):]
    fade = np.linspace(0, 1, len(tail))
    body[: len(tail)] = body[: len(tail)] * fade + tail * (1 - fade)
    return body

def ocean():
    sec = 32.0
    L = loopnoise(sec, lambda x: lp(x, 160)) * 0.5 + loopnoise(sec, lambda x: bp(x, 900, 6000)) * 0.05 * smooth_env(sec, 0.3, 0.5, 1.0)
    R = loopnoise(sec, lambda x: lp(x, 160)) * 0.5 + loopnoise(sec, lambda x: bp(x, 900, 6000)) * 0.05 * smooth_env(sec, 0.3, 0.5, 1.0)
    at = 0.0
    while at < sec:
        period = rng.uniform(5.0, 7.5)
        build, wash = rng.uniform(1.6, 2.6), rng.uniform(6.0, 8.0)
        d = build + wash
        x = tt(d)
        tail = np.clip((d - x) / 2.0, 0, 1) ** 1.5
        e_build = np.clip(x / build, 0, 1) ** 2.2
        after = np.clip(x - build, 0, None)
        roar_env = e_build * np.where(x > build, np.exp(-after / (wash / 3.0)), 1.0) * tail
        foam_env = np.where(x > build, np.minimum(1.0, after / 0.08) * np.exp(-after / (wash / 2.2)), 0) * tail
        pan = rng.uniform(-0.6, 0.6); g = np.pi * (pan + 1) / 4
        size = rng.uniform(0.7, 1.2)
        place(L, (lp(n(d), 900) * roar_env + bp(n(d), 1500, 9000) * foam_env * 0.38) * np.cos(g) * size, at)
        place(R, (lp(n(d), 900) * roar_env + bp(n(d), 1500, 9000) * foam_env * 0.38) * np.sin(g) * size, at)
        at += period
    L = reverb(L, 1.2, 3000, 0.2); R = reverb(R, 1.2, 3000, 0.2)
    save("amb_ocean", L, R, 0.75)

def bird_whistle(f0, f1, d):
    x = tt(d); f = np.linspace(f0, f1, len(x)) * (1 + 0.012 * np.sin(2 * np.pi * 7 * x))
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * x / d) ** 1.5
    return s
def bird_trill(f, notes, rate):
    out = np.zeros(int(SR * notes / rate) + int(SR * 0.05))
    for k in range(notes):
        place(out, bird_whistle(f * rng.uniform(0.97, 1.03), f * 1.25, 0.035), k / rate)
    return out
def bird_warble(fc, d):
    x = tt(d); mod = 380 * np.sin(2 * np.pi * rng.uniform(18, 32) * x)
    return np.sin(2 * np.pi * np.cumsum(fc + mod) / SR) * np.sin(np.pi * x / d) ** 2
def dove(d=1.6):
    out = np.zeros(int(SR * d))
    for (at, f, ln) in [(0.0, 520, 0.35), (0.42, 600, 0.55), (1.05, 480, 0.4)]:
        x = tt(ln); s = np.sin(2 * np.pi * f * x) * np.sin(np.pi * x / ln) ** 2 + 0.3 * np.sin(4 * np.pi * f * x) * np.sin(np.pi * x / ln) ** 2
        place(out, lp(s, 1500), at)
    return out

def forest():
    sec = 40.0
    L = loopnoise(sec, lambda x: bp(x, 400, 3000)) * 0.05 * smooth_env(sec, 0.3, 0.4, 1.0)
    R = loopnoise(sec, lambda x: bp(x, 400, 3000)) * 0.05 * smooth_env(sec, 0.3, 0.4, 1.0)
    species = [
        lambda: bird_whistle(rng.uniform(2600, 3200), rng.uniform(3600, 4200), rng.uniform(0.25, 0.4)),
        lambda: np.concatenate([bird_whistle(3900, 3900, 0.18), np.zeros(int(SR * 0.08)), bird_whistle(3300, 3200, 0.24)]),
        lambda: bird_trill(rng.uniform(4200, 5200), rng.integers(8, 16), rng.uniform(14, 22)),
        lambda: bird_warble(rng.uniform(2400, 3200), rng.uniform(0.5, 0.9)),
        lambda: dove() * 0.4,
        lambda: np.concatenate([bird_whistle(f, f * 0.92, 0.09) for f in rng.uniform(2800, 3800, 5)]),
    ]
    for sp, (rate, vol, dist) in zip(species, [(0.35, 0.5, 0.6), (0.25, 0.45, 0.9), (0.22, 0.35, 0.5), (0.2, 0.35, 1.2), (0.12, 0.45, 2.4), (0.18, 0.35, 0.8)]):
        pan = rng.uniform(-0.85, 0.85)
        at = rng.uniform(0, 3)
        while at < sec:
            s = sp() * vol
            if dist > 1.0: s = lp(s, 4500 / dist)
            pan_place(L, R, s, at, pan + rng.uniform(-0.1, 0.1))
            at += rng.exponential(1 / rate) + 0.6
    L = reverb(L, 1.4, 5000, 0.28); R = reverb(R, 1.4, 5000, 0.28)
    save("amb_forest", L, R, 0.6)

def rain():
    sec = 24.0
    L = loopnoise(sec, lambda x: lp(hp(x, 300), 5000)) * 0.12; R = loopnoise(sec, lambda x: lp(hp(x, 300), 5000)) * 0.12
    drop_len = int(SR * 0.006)
    base = np.exp(-np.arange(drop_len) / (SR * 0.0012))
    for ch in (L, R):
        k = int(sec * 900)
        pos = rng.integers(0, len(ch), k)
        amp = rng.lognormal(-1.4, 0.7, k)
        imp = np.zeros(len(ch)); np.add.at(imp, pos, amp)
        drops = np.convolve(imp, base)[: len(ch)]
        ch += bp(drops, 1200, 7000) * 0.9
    for i in range(int(sec * 1.5)):
        f0 = rng.uniform(900, 1500); d = 0.06; x = tt(d)
        blip = np.sin(2 * np.pi * np.cumsum(np.linspace(f0, f0 * 1.6, len(x))) / SR) * np.exp(-x / 0.015) * 0.25
        pan_place(L, R, blip, rng.uniform(0, sec), rng.uniform(-0.9, 0.9))
    L = reverb(L, 0.8, 6000, 0.15); R = reverb(R, 0.8, 6000, 0.15)
    save("amb_rain", L, R, 0.6)

def stream():
    sec = 18.0
    bedL = loopnoise(sec, lambda x: bp(x, 200, 1800)) * smooth_env(sec, 1.5, 0.5, 1.0) * 0.4
    bedR = loopnoise(sec, lambda x: bp(x, 200, 1800)) * smooth_env(sec, 1.5, 0.5, 1.0) * 0.4
    L, R = bedL, bedR
    for i in range(int(sec * 70)):
        d = rng.uniform(0.015, 0.05); f0 = rng.uniform(300, 1200); x = tt(d)
        b = np.sin(2 * np.pi * np.cumsum(np.linspace(f0, f0 * rng.uniform(1.4, 2.2), len(x))) / SR) * np.sin(np.pi * x / d) * rng.uniform(0.1, 0.5)
        pan_place(L, R, b, rng.uniform(0, sec), rng.uniform(-0.8, 0.8))
    L = reverb(L, 0.6, 4000, 0.15); R = reverb(R, 0.6, 4000, 0.15)
    save("amb_stream", L, R, 0.6)

def falls():
    sec = 14.0
    L = loopnoise(sec, lambda x: lp(x, 2500)) * smooth_env(sec, 2, 0.8, 1.0) + loopnoise(sec, lambda x: lp(x, 120)) * 0.8
    R = loopnoise(sec, lambda x: lp(x, 2500)) * smooth_env(sec, 2, 0.8, 1.0) + loopnoise(sec, lambda x: lp(x, 120)) * 0.8
    save("amb_falls", L, R, 0.65)

def night():
    sec = 30.0
    L = np.zeros(int(SR * sec)); R = np.zeros(int(SR * sec))
    for sp in range(5):
        f = rng.uniform(3800, 5600); pan = rng.uniform(-0.9, 0.9); vol = rng.uniform(0.15, 0.4)
        at = rng.uniform(0, 1)
        while at < sec:
            chirp = np.zeros(int(SR * 0.25))
            for p in range(rng.integers(2, 5)):
                x = tt(0.022); place(chirp, np.sin(2 * np.pi * f * x) * np.sin(np.pi * x / 0.022), p * 0.04)
            pan_place(L, R, chirp * vol, at, pan)
            at += rng.uniform(0.5, 0.9)
    trill = np.sin(2 * np.pi * 5200 * tt(sec)) * (0.5 + 0.5 * np.sin(2 * np.pi * 42 * tt(sec))) * smooth_env(sec, 0.4, 0.0, 1.0) * 0.06
    L += trill * 0.7; R += trill
    for i in range(int(sec / 3)):
        d = 0.35; x = tt(d)
        frog = (np.sin(2 * np.pi * 280 * x) + 0.5 * np.sin(2 * np.pi * 560 * x)) * (0.5 + 0.5 * np.sign(np.sin(2 * np.pi * 28 * x))) * np.sin(np.pi * x / d)
        pan_place(L, R, lp(frog, 1800) * 0.3, rng.uniform(0, sec), rng.uniform(-0.8, 0.8))
    L = reverb(L, 1.0, 6000, 0.3) + loopnoise(sec, lambda x: lp(x, 300)) * 0.02
    R = reverb(R, 1.0, 6000, 0.3) + loopnoise(sec, lambda x: lp(x, 300)) * 0.02
    save("amb_night", L, R, 0.5)

def wind():
    sec = 24.0
    g = smooth_env(sec, 0.25, 0.15, 1.0)
    L = loopnoise(sec, lambda x: bp(x, 250, 2200)) * g + loopnoise(sec, lambda x: lp(x, 200)) * 0.3 * g
    R = loopnoise(sec, lambda x: bp(x, 250, 2200)) * g[::-1] + loopnoise(sec, lambda x: lp(x, 200)) * 0.3 * g
    save("amb_wind", L, R, 0.55)

def cave():
    sec = 30.0
    L = loopnoise(sec, lambda x: lp(x, 90)) * 0.25 + loopnoise(sec, lambda x: bp(x, 150, 700)) * smooth_env(sec, 0.4, 0.2, 1.0) * 0.08
    R = loopnoise(sec, lambda x: lp(x, 90)) * 0.25 + loopnoise(sec, lambda x: bp(x, 150, 700)) * smooth_env(sec, 0.4, 0.2, 1.0) * 0.08
    at = 0.3
    while at < sec:
        d = 0.09; x = tt(d); f0 = rng.uniform(900, 2200)
        plink = np.sin(2 * np.pi * np.cumsum(f0 * (1 + 1.6 * (x / d) ** 1.5)) / SR) * np.exp(-x / 0.02)
        pan_place(L, R, plink * rng.uniform(0.3, 0.8), at, rng.uniform(-0.8, 0.8))
        at += rng.uniform(0.5, 2.6)
    L = reverb(L, 3.5, 3500, 0.55); R = reverb(R, 3.5, 3500, 0.55)
    save("amb_cave", L, R, 0.6)

def underwater():
    sec = 20.0
    L = loopnoise(sec, lambda x: lp(x, 220)) * smooth_env(sec, 0.3, 0.6, 1.0) + loopnoise(sec, lambda x: lp(x, 60)) * 0.6
    R = loopnoise(sec, lambda x: lp(x, 220)) * smooth_env(sec, 0.3, 0.6, 1.0) + loopnoise(sec, lambda x: lp(x, 60)) * 0.6
    for i in range(int(sec / 2.5)):
        at = rng.uniform(0, sec); pan = rng.uniform(-0.6, 0.6)
        for k in range(rng.integers(3, 8)):
            d = 0.05; x = tt(d); f0 = rng.uniform(250, 600)
            b = np.sin(2 * np.pi * np.cumsum(np.linspace(f0, f0 * 2.0, len(x))) / SR) * np.sin(np.pi * x / d) * 0.12
            pan_place(L, R, lp(b, 1200), at + k * rng.uniform(0.07, 0.15), pan)
    L = reverb(L, 2.0, 1500, 0.4); R = reverb(R, 2.0, 1500, 0.4)
    save("amb_underwater", L, R, 0.6)

if __name__ == "__main__":
    for f in (ocean, forest, rain, stream, falls, night, wind, cave, underwater):
        f(); print("made", f.__name__)
