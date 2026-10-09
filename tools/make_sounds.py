"""Generate every sound in Varnak Island from code (no outside recordings).
Run: python3 tools/make_sounds.py   (needs numpy and ffmpeg). Writes sfx/*.ogg."""
import os, subprocess, tempfile, wave
import numpy as np

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "sfx")
rng = np.random.default_rng(7)

def t(sec): return np.arange(int(SR * sec)) / SR
def env(n, a=0.005, d=0.2):
    x = np.arange(n) / SR
    e = np.minimum(1.0, x / max(a, 1e-4)) * np.exp(-x / max(d, 1e-4))
    return e
def sine(f, sec): return np.sin(2 * np.pi * f * t(sec))
def sweep(f0, f1, sec):
    ph = 2 * np.pi * np.cumsum(np.linspace(f0, f1, int(SR * sec))) / SR
    return np.sin(ph)
def noise(sec): return rng.uniform(-1, 1, int(SR * sec))
def lowpass(x, cut):
    a = np.exp(-2 * np.pi * cut / SR)
    y = np.zeros_like(x); s = 0.0
    for i, v in enumerate(x):
        s = (1 - a) * v + a * s
        y[i] = s
    return y
def bandpass(x, lo, hi): return lowpass(x, hi) - lowpass(x, lo)
def tri(f, sec):
    ph = (f * t(sec)) % 1.0
    return 4 * np.abs(ph - 0.5) - 1
def saw(f, sec, vib=0.0, vf=5.0):
    tt = t(sec)
    ph = np.cumsum(f * (1 + vib * np.sin(2 * np.pi * vf * tt))) / SR
    return 2 * (ph % 1.0) - 1
def place(buf, x, at):
    i = int(at * SR)
    j = min(len(buf), i + len(x))
    if j > i: buf[i:j] += x[: j - i]
def norm(x, peak=0.8):
    m = np.max(np.abs(x)) or 1.0
    return x / m * peak
def fade(x, a=0.01, b=0.05):
    n = len(x); na = int(a * SR); nb = int(b * SR)
    if na: x[:na] *= np.linspace(0, 1, na)
    if nb: x[-nb:] *= np.linspace(1, 0, nb)
    return x

def save(name, x, peak=0.8, loop=False):
    x = norm(x, peak) if not loop else norm(x, peak)
    pcm = (np.clip(x, -1, 1) * 32767).astype(np.int16)
    os.makedirs(OUT, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        tmp = f.name
    with wave.open(tmp, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", tmp, "-c:a", "libvorbis", "-q:a", "3", os.path.join(OUT, name + ".ogg")], check=True)
    os.remove(tmp)

def bell(f, sec=0.6, d=0.25):
    return (sine(f, sec) + 0.4 * sine(2 * f, sec) + 0.2 * sine(3 * f, sec)) * env(int(SR * sec), 0.003, d)

def clap():
    n = noise(0.09)
    return bandpass(n, 900, 3000) * env(len(n), 0.001, 0.02)

def applause(sec, rate, cheer=False):
    buf = np.zeros(int(SR * sec))
    k = int(rate * sec)
    for i in range(k):
        at = rng.uniform(0, sec - 0.1)
        place(buf, clap() * rng.uniform(0.3, 1.0), at)
    shape = np.minimum(1, t(sec) / 0.25) * np.minimum(1, (sec - t(sec)) / 0.8)
    buf *= shape
    if cheer:
        w = saw(330, sec, 0.02, 6) * 0.04 + saw(440, sec, 0.03, 5) * 0.03
        buf += lowpass(w, 1500) * shape
    return buf

def main():
    # feedback
    x = np.zeros(int(SR * 0.7)); place(x, bell(1046.5, 0.5, 0.18), 0); place(x, bell(1318.5, 0.5, 0.25), 0.09); save("correct", x, 0.6)
    x = sweep(160, 70, 0.3) * env(int(SR * 0.3), 0.003, 0.09); save("wrong", x, 0.6)
    x = np.zeros(int(SR * 0.3)); place(x, bell(1975, 0.2, 0.06), 0); place(x, bell(2637, 0.25, 0.09), 0.07); save("coin", x, 0.55)
    x = np.zeros(int(SR * 1.2))
    for i, f in enumerate([523.25, 659.25, 783.99, 1046.5]): place(x, tri(f, 0.5) * env(int(SR * 0.5), 0.005, 0.25), i * 0.12)
    place(x, tri(1046.5, 0.6) * env(int(SR * 0.6), 0.01, 0.4) * 0.8, 0.5); save("fanfare", x, 0.6)
    x = np.zeros(int(SR * 0.5))
    for i, f in enumerate([1568, 2093, 2637]): place(x, bell(f, 0.3, 0.07) * 0.7, i * 0.06)
    save("newword", x, 0.35)
    x = sweep(300, 900, 0.12) * env(int(SR * 0.12), 0.002, 0.04); save("pop", x, 0.6)
    x = bandpass(noise(0.7), 300, 2500) * np.sin(np.pi * t(0.7) / 0.7) ** 2; save("whoosh", x, 0.5)
    n = lowpass(noise(1.2), 400) * env(int(SR * 1.2), 0.002, 0.35) + sweep(70, 35, 1.2) * env(int(SR * 1.2), 0.002, 0.3); save("kabum", n, 0.8)
    x = bandpass(noise(0.4), 200, 1800) * env(int(SR * 0.4), 0.004, 0.12); save("page", x, 0.45)
    x = np.zeros(int(SR * 0.8)); place(x, bandpass(noise(0.5), 400, 3000) * env(int(SR * 0.5), 0.002, 0.15), 0)
    for i in range(6): place(x, bell(rng.uniform(900, 1800), 0.12, 0.03) * 0.3, rng.uniform(0.1, 0.6))
    save("splash", x, 0.6)
    for k in range(2):
        x = lowpass(noise(0.12), 500 + 150 * k) * env(int(SR * 0.12), 0.002, 0.03); save("step%d" % k, x, 0.35)
    # applause and its absence
    save("applause_small", applause(1.6, 10), 0.6)
    save("applause_big", applause(3.0, 30, True), 0.75)
    save("applause_huge", applause(4.5, 60, True), 0.85)
    x = np.zeros(int(SR * 2.6))
    for i in range(3): place(x, clap(), 0.3 + i * 0.8)
    save("slowclap", x, 0.5)
    x = np.zeros(int(SR * 2.0))
    for c in range(3):
        for p in range(4): place(x, sine(4600, 0.018) * env(int(SR * 0.018), 0.001, 0.008), 0.2 + c * 0.6 + p * 0.03)
    save("cricket", x, 0.35)
    # Guarani sound words
    x = np.zeros(int(SR * 1.4))
    for i in range(14): place(x, sweep(rng.uniform(400, 700), rng.uniform(900, 1400), 0.05) * env(int(SR * 0.05), 0.001, 0.015), rng.uniform(0, 1.3))
    save("pororo", x, 0.6)
    x = np.zeros(int(SR * 1.2))
    for i in range(40): place(x, bell(rng.uniform(2500, 5000), 0.05, 0.01) * rng.uniform(0.2, 0.7), rng.uniform(0, 1.15))
    save("piriri", x, 0.45)
    x = bandpass(noise(1.6), 2500, 7000) * (0.6 + 0.4 * np.sin(2 * np.pi * 3 * t(1.6)))
    for i in range(25): place(x, bandpass(noise(0.01), 1000, 6000) * 3, rng.uniform(0, 1.55))
    save("chiriri", fade(x, 0.05, 0.3), 0.45)
    x = lowpass(noise(1.6), 250) * (0.7 + 0.3 * np.sin(2 * np.pi * 9 * t(1.6))) + 0.4 * saw(70, 1.6, 0.05, 7) * 0.3
    save("guarara", fade(x, 0.15, 0.4), 0.75)
    tt = t(2.6); breath = np.clip(np.sin(2 * np.pi * tt / 2.6), 0, 1)
    x = lowpass(noise(2.6), 300) * breath * (0.6 + 0.4 * np.sign(np.sin(2 * np.pi * 28 * tt))) + saw(55, 2.6) * 0.15 * breath
    save("kororo", x, 0.6)
    x = np.zeros(int(SR * 1.3))
    for i, (f, d) in enumerate([(523.25, 0.18), (523.25, 0.18), (659.25, 0.18), (783.99, 0.55)]):
        place(x, lowpass(saw(f, d + 0.05, 0.01, 6), 2200) * env(int(SR * (d + 0.05)), 0.02, d * 0.8), [0, 0.22, 0.44, 0.66][i])
    save("tarara", x, 0.6)
    x = np.zeros(int(SR * 1.0))
    for i in range(10): place(x, bandpass(noise(0.04), 600, 4000) * env(int(SR * 0.04), 0.001, 0.012), i * 0.09 + rng.uniform(0, 0.02))
    save("pururu", x, 0.55)
    x = lowpass(noise(2.0), 900) * 0.3
    for i in range(30): place(x, sweep(rng.uniform(600, 900), rng.uniform(1200, 1800), 0.03) * env(int(SR * 0.03), 0.001, 0.01) * 0.5, rng.uniform(0, 1.95))
    save("siri", fade(x, 0.2, 0.4), 0.45)
    tt = t(1.6); x = np.sin(2 * np.pi * np.cumsum(440 + 80 * np.sin(2 * np.pi * 2.5 * tt)) / SR) * env(len(tt), 0.05, 1.0)
    save("vava", x, 0.5)
    x = lowpass(noise(2.2), 150) * 1.2 + applause(2.2, 25) * 0.5
    for i in range(8): place(x, sweep(90, 45, 0.25) * env(int(SR * 0.25), 0.002, 0.08), i * 0.27)
    save("sununu", fade(x, 0.2, 0.5), 0.7)
    # ambience loops live in make_ambience.py
    for k in range(3):
        x = np.zeros(int(SR * 0.6))
        for i in range(2 + k):
            f0 = rng.uniform(2500, 3800)
            place(x, sweep(f0, f0 * rng.uniform(1.15, 1.4), 0.07) * env(int(SR * 0.07), 0.003, 0.03), i * 0.1)
        save("bird%d" % k, x, 0.3)
    desh_song()

def desh_song():
    """A short, cheerful cumbia loop for Desh (kachaka!): G and D chords, bass, guiro, drum, accordion."""
    bpm = 96.0
    beat = 60.0 / bpm
    bars = 8
    sec = bars * 4 * beat
    buf = np.zeros(int(SR * sec))
    G = {"G": [196.0, 246.94, 293.66], "D": [146.83, 185.0, 220.0], "C": [130.81, 164.81, 196.0]}
    prog = ["G", "G", "D", "D", "C", "G", "D", "G"]
    roots = {"G": 98.0, "D": 73.42, "C": 65.41}
    melody = [(0, 587.33), (1, 659.25), (1.5, 587.33), (2, 493.88), (3, 392.0),
              (4, 440.0), (5, 493.88), (6, 440.0), (7, 369.99),
              (8, 392.0), (9, 440.0), (9.5, 493.88), (10, 587.33), (11, 493.88),
              (12, 440.0), (13, 392.0), (14, 369.99), (15, 392.0)]
    for b in range(bars):
        ch = prog[b]; r = roots[ch]; t0 = b * 4 * beat
        # bass: root on 1, fifth on 3
        place(buf, tri(r, beat * 0.9) * env(int(SR * beat * 0.9), 0.005, 0.4) * 0.9, t0)
        place(buf, tri(r * 1.5, beat * 0.9) * env(int(SR * beat * 0.9), 0.005, 0.4) * 0.8, t0 + 2 * beat)
        for q in range(4):
            tq = t0 + q * beat
            # kick on 1 and 3, chord stabs on the off-beats
            if q % 2 == 0: place(buf, sweep(110, 45, 0.18) * env(int(SR * 0.18), 0.002, 0.06) * 0.9, tq)
            for f in G[ch]: place(buf, lowpass(saw(f, beat * 0.35, 0.004, 6), 1800) * env(int(SR * beat * 0.35), 0.005, 0.08) * 0.18, tq + beat * 0.5)
            # guiro: long-short-short scratch, the "cha-ka-cha"
            for (o, ln) in [(0.0, 0.22), (0.5, 0.08), (0.75, 0.08)]:
                g = bandpass(noise(ln), 2500, 7000) * (0.5 + 0.5 * np.sign(np.sin(2 * np.pi * 60 * t(ln)))) * env(int(SR * ln), 0.003, ln * 0.6) * 0.12
                place(buf, g, tq + o * beat)
    for rep in range(2):
        for (bt, f) in melody:
            st = rep * 16 * beat + bt * beat
            ln = beat * 0.9
            note = lowpass(saw(f, ln, 0.006, 5.5) + 0.5 * saw(f * 1.005, ln), 2400) * env(int(SR * ln), 0.02, ln * 0.7)
            place(buf, note * 0.35, st)
    save("desh_song", buf, 0.7, True)
    save("kachaka", fade(buf[: int(SR * 3.2)].copy(), 0.01, 0.4), 0.7)

if __name__ == "__main__":
    main()
