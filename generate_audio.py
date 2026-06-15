import math
import struct
import wave
import random
import os

SAMPLE_RATE = 44100
AUDIO_DIR = r'z:\home\marcin\projects\Fruit-Games\assets\audio'

def save_wav(filename, samples):
    path = os.path.join(AUDIO_DIR, filename)
    # Clip samples to -1.0 to 1.0 to avoid clipping distortion
    clipped = [max(-1.0, min(1.0, s)) for s in samples]
    with wave.open(path, 'w') as wav_file:
        wav_file.setnchannels(1) # Mono
        wav_file.setsampwidth(2) # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        # Convert float to short int
        wav_file.writeframes(struct.pack('%dh' % len(clipped), *[int(s * 32767.0) for s in clipped]))
    print(f"Nadpisano: {filename}")

def generate_jump():
    # Miękki, rosnący dźwięk bazujący na fali sinusoidalnej
    duration = 0.25
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = max(0, 1.0 - (t / duration)) # Liniowy zanik
        # Tonacja rośnie
        phase = 2 * math.pi * (350 * t + 150 * t * t / duration)
        sample = math.sin(phase) * env * 0.3
        samples.append(sample)
    return samples

def generate_shoot():
    # Miękki 'pew' / 'thwip' - gwałtownie opadająca tonacja
    duration = 0.15
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 25)
        # Faza uwzględnia opadającą tonację (całka)
        phase = 2 * math.pi * 900 * (1 - math.exp(-t * 35)) / 35
        # Fala trójkątna jest łagodniejsza niż kwadratowa
        val = (phase / (2*math.pi)) % 1.0
        sample = (val * 2 - 1) * env * 0.15
        samples.append(sample)
    return samples

def generate_hit():
    # Głuchy 'squish' / thud - uderzenie w owoc (niskie tony + szum)
    duration = 0.2
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env_noise = math.exp(-t * 40)
        env_thump = math.exp(-t * 15)
        
        noise = random.uniform(-1, 1) * env_noise * 0.1
        phase = 2 * math.pi * 120 * t
        thump = math.sin(phase) * env_thump * 0.3
        
        samples.append(noise + thump)
    return samples

def generate_ui_click():
    # Przyjemny, krótki 'pop'
    duration = 0.05
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 80)
        phase = 2 * math.pi * 600 * t
        sample = math.sin(phase) * env * 0.2
        samples.append(sample)
    return samples

def generate_melee():
    # Miękki 'whoosh' / świst powitrza (filtrowany szum)
    duration = 0.2
    samples = []
    prev_noise = 0
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = math.sin(t / duration * math.pi) # paraboliczna obwiednia
        noise = random.uniform(-1, 1)
        prev_noise = prev_noise + 0.08 * (noise - prev_noise) # Prosty filtr dolnoprzepustowy
        sample = prev_noise * env * 0.6
        samples.append(sample)
    return samples

def generate_death():
    # Smutny, opadający, łagodny dźwięk
    duration = 0.8
    samples = []
    for i in range(int(SAMPLE_RATE * duration)):
        t = i / SAMPLE_RATE
        env = max(0, 1.0 - (t / duration))
        phase = 2 * math.pi * (300 * t - 150 * t * t / duration)
        sample = math.sin(phase) * env * 0.3
        samples.append(sample)
    return samples

if __name__ == '__main__':
    print("Rozpoczynam syntezę łagodnych dźwięków w Pythonie...")
    save_wav('jump.wav', generate_jump())
    save_wav('shoot.wav', generate_shoot())
    save_wav('hit.wav', generate_hit())
    save_wav('ui_click.wav', generate_ui_click())
    save_wav('melee.wav', generate_melee())
    save_wav('death.wav', generate_death())
    print("Synteza zakończona! Wróć do Godota i posłuchaj różnicy.")