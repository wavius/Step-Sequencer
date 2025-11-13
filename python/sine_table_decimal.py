import numpy as np

N = 4096
A = (2**32) / 2 - 1        # 32-bit signed max amplitude
sine = (A * (np.sin(2 * np.pi * np.arange(N) / N) / 64)).astype(int)  # 1/4 scale

with open("sine4096.mif", "w") as f:
    f.write("WIDTH = 32;\nDEPTH = 4096;\nADDRESS_RADIX = UNS;\nDATA_RADIX = DEC;\nCONTENT BEGIN\n")
    for i, v in enumerate(sine):
        if v < 0:
            v = (1 << 32) + v   # wrap negative values to unsigned 32-bit
        f.write(f"{i} : {v};\n")
    f.write("END;\n")
