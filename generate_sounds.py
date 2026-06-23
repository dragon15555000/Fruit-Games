import wave
import math
import struct
import random
import os

SAMPLE_RATE = 44100

def save_wav(filename, samples):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        for sample in samples:
            # Clamp sample to [-1.0, 1.0]
            s = max(-1.0, min(1.0, sample))
            wav_file.writeframes(struct.pack('h', int(s * 32767.0)))

def generate_shoot():
    samples = []
    duration = 0.1
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 30)
        # Squeaky popping sound: high pitch dropping fast
        freq = 1500 - 8000 * t
        freq = max(300, freq)
        val = math.sin(2 * math.pi * freq * t)
        samples.append(val * env * 0.4)
    return samples

def generate_jump():
    samples = []
    duration = 0.25
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = 1.0 - (t / duration)
        # Classic "Boing"
        freq = 400 + 1500 * t
        val = math.sin(2 * math.pi * freq * t)
        samples.append(val * env * 0.4)
    return samples

def generate_hit():
    samples = []
    duration = 0.15
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 15)
        # Squeaky "Ouch" (high pitched fast vibrato)
        vibrato = math.sin(2 * math.pi * 30 * t) * 50
        freq = 1200 + vibrato
        val = math.sin(2 * math.pi * freq * t)
        samples.append(val * env * 0.4)
    return samples

def generate_death():
    samples = []
    duration = 0.5
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = 1.0 - (t / duration)
        # Squeaky "Oh no!" falling down
        freq = 1500 - 2000 * t
        freq = max(200, freq)
        val = math.sin(2 * math.pi * freq * t)
        samples.append(val * env * 0.4)
    return samples

def generate_ui_click():
    samples = []
    duration = 0.05
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = 1.0 - (t / duration)
        freq = 600
        val = math.sin(2 * math.pi * freq * t)
        samples.append(val * env * 0.4)
    return samples

def generate_melee():
    samples = []
    duration = 0.15
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = math.sin(t / duration * math.pi)
        val = random.uniform(-1.0, 1.0)
        # Lowpass filter effect simulated by just using lower frequency noise or smoothing, we just do white noise + envelope
        samples.append(val * env * 0.3)
    return samples

def generate_bgm():
    samples = []
    duration = 8.0
    pads = [
        (196.00, 0.0, 2.4), (233.08, 0.4, 2.4), (174.61, 2.0, 2.8),
        (220.00, 2.8, 2.6), (164.81, 4.4, 2.6), (196.00, 5.6, 2.4),
        (174.61, 6.5, 1.5), (146.83, 7.2, 0.8)
    ]
    arps = [
        (392.00, 0.0, 0.18), (523.25, 0.25, 0.18), (659.25, 0.5, 0.18), (783.99, 0.75, 0.18),
        (392.00, 1.0, 0.18), (466.16, 1.25, 0.18), (587.33, 1.5, 0.18), (698.46, 1.75, 0.18),
        (349.23, 2.0, 0.18), (493.88, 2.25, 0.18), (587.33, 2.5, 0.18), (739.99, 2.75, 0.18),
        (329.63, 3.0, 0.18), (415.30, 3.25, 0.18), (554.37, 3.5, 0.18), (659.25, 3.75, 0.18),
        (311.13, 4.0, 0.18), (392.00, 4.25, 0.18), (493.88, 4.5, 0.18), (622.25, 4.75, 0.18),
        (349.23, 5.0, 0.18), (440.00, 5.25, 0.18), (554.37, 5.5, 0.18), (698.46, 5.75, 0.18),
        (261.63, 6.0, 0.18), (329.63, 6.25, 0.18), (392.00, 6.5, 0.18), (523.25, 6.75, 0.18),
        (220.00, 7.0, 0.35), (261.63, 7.35, 0.35)
    ]
    bass_notes = [(110.00, 0.0, 2.0), (130.81, 2.0, 2.0), (98.00, 4.0, 2.0), (87.31, 6.0, 2.0)]
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        val = 0.0

        # Pad: miękka, szeroka podbudowa klimatu
        for freq, start, length in pads:
            if start <= t < start + length:
                local_t = t - start
                env = math.sin(min(1.0, local_t / length) * math.pi)
                osc = math.sin(2 * math.pi * freq * local_t) * 0.45 + math.sin(2 * math.pi * freq * 0.5 * local_t) * 0.18
                val += osc * env * 0.12

        # Arpeggio: daje poczucie ruchu bez agresji
        for freq, start, length in arps:
            if start <= t < start + length:
                local_t = t - start
                env = math.exp(-local_t * 10)
                osc = 2.0 * abs(2.0 * (local_t * freq - math.floor(local_t * freq + 0.5))) - 1.0
                shimmer = math.sin(2 * math.pi * freq * 2.0 * local_t) * 0.08
                val += (osc + shimmer) * env * 0.09

        # Bass
        for freq, start, length in bass_notes:
            if start <= t < start + length:
                local_t = t - start
                env = math.exp(-local_t * 2.2)
                osc = math.sin(2 * math.pi * freq * local_t) * 0.8
                sub = math.sin(2 * math.pi * freq * 0.5 * local_t) * 0.35
                val += (osc + sub) * env * 0.16

        # Delikatny pulse perkusyjny
        kick_interval = 1.0
        hihat_interval = 0.5
        kick_t = t % kick_interval
        if kick_t < 0.12:
            val += math.sin(2 * math.pi * (90 - 650 * kick_t) * kick_t) * math.exp(-kick_t * 24) * 0.22
        hihat_t = t % hihat_interval
        if hihat_t < 0.03:
            val += random.uniform(-1.0, 1.0) * math.exp(-hihat_t * 60) * 0.025

        samples.append(val)

    return samples

def generate_bgm_combat():
    samples = []
    duration = 8.0
    notes = [
        (659.25, 0.0, 0.15), (783.99, 0.15, 0.15), (880.00, 0.3, 0.15), (987.77, 0.45, 0.15),
        (1046.50, 0.6, 0.15), (987.77, 0.75, 0.15), (880.00, 0.9, 0.15), (783.99, 1.05, 0.15),
        (659.25, 1.2, 0.15), (739.99, 1.35, 0.15), (830.61, 1.5, 0.15), (987.77, 1.65, 0.15),
        (1046.50, 1.8, 0.15), (987.77, 1.95, 0.15), (830.61, 2.1, 0.15), (739.99, 2.25, 0.15),
        (659.25, 2.4, 0.15), (783.99, 2.55, 0.15), (880.00, 2.7, 0.15), (1046.50, 2.85, 0.15),
        (1174.66, 3.0, 0.15), (1046.50, 3.15, 0.15), (880.00, 3.3, 0.15), (783.99, 3.45, 0.15),
        (659.25, 3.6, 0.15), (622.25, 3.75, 0.15), (587.33, 3.9, 0.15), (554.37, 4.05, 0.15),
        (659.25, 4.2, 0.15), (783.99, 4.35, 0.15), (880.00, 4.5, 0.15), (987.77, 4.65, 0.15),
        (1046.50, 4.8, 0.15), (987.77, 4.95, 0.15), (880.00, 5.1, 0.15), (783.99, 5.25, 0.15),
        (659.25, 5.4, 0.15), (739.99, 5.55, 0.15), (830.61, 5.7, 0.15), (987.77, 5.85, 0.15),
        (1046.50, 6.0, 0.15), (987.77, 6.15, 0.15), (830.61, 6.3, 0.15), (739.99, 6.45, 0.15),
        (659.25, 6.6, 0.15), (622.25, 6.75, 0.15), (587.33, 6.9, 0.15), (554.37, 7.05, 0.15),
        (659.25, 7.2, 0.4), (783.99, 7.6, 0.4)
    ]
    bass_notes = [
        (110.0, 0.0, 2.0), (146.83, 2.0, 2.0), (130.81, 4.0, 2.0), (98.00, 6.0, 2.0)
    ]
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        val = 0.0
        for freq, start, length in notes:
            if start <= t < start + length:
                local_t = t - start
                env = math.exp(-local_t * 8.5)
                osc = 2.0 * abs(2.0 * (local_t * freq - math.floor(local_t * freq + 0.5))) - 1.0
                pulse = math.sin(2 * math.pi * freq * 2.0 * local_t) * 0.1
                val += (osc + pulse) * env * 0.14
        for freq, start, length in bass_notes:
            if start <= t < start + length:
                local_t = t - start
                env = math.exp(-local_t * 2.5)
                osc = math.sin(2 * math.pi * freq * local_t) * 0.85
                sub = math.sin(2 * math.pi * freq * 0.5 * local_t) * 0.4
                val += (osc + sub) * env * 0.18
        kick_t = t % 0.5
        if kick_t < 0.09:
            val += math.sin(2 * math.pi * (80 - 900 * kick_t) * kick_t) * math.exp(-kick_t * 34) * 0.3
        hihat_t = t % 0.25
        if hihat_t < 0.025:
            val += random.uniform(-1.0, 1.0) * math.exp(-hihat_t * 90) * 0.03
        samples.append(val)
    return samples

if __name__ == "__main__":
    out_dir = "assets/audio"
    print(f"Generating sounds in {out_dir}...")
    save_wav(f"{out_dir}/shoot.wav", generate_shoot())
    save_wav(f"{out_dir}/jump.wav", generate_jump())
    save_wav(f"{out_dir}/hit.wav", generate_hit())
    save_wav(f"{out_dir}/death.wav", generate_death())
    save_wav(f"{out_dir}/ui_click.wav", generate_ui_click())
    save_wav(f"{out_dir}/melee.wav", generate_melee())
    save_wav(f"{out_dir}/bgm.wav", generate_bgm())
    save_wav(f"{out_dir}/bgm_combat.wav", generate_bgm_combat())
    print("Done!")
