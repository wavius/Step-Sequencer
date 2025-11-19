import numpy as np

N = 512
A = (2**16) / 2 - 1        # 32-bit signed max amplitude
sine = (A * (np.sin(2 * np.pi * np.arange(N) / N) / 16)).astype(int)  # 1/4 scale

with open("sine512.mif", "w") as f:
    f.write("WIDTH = 16;\nDEPTH = 512;\nADDRESS_RADIX = UNS;\nDATA_RADIX = DEC;\nCONTENT BEGIN\n")
    for i, v in enumerate(sine):
        if v < 0:
            v = (1 << 16) + v   # wrap negative values to unsigned 32-bit
        f.write(f"{i} : {v};\n")
    f.write("END;\n")
