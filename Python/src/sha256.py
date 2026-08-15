# THIS FILE CONTAINS THE ...

from src import rotate_right, shift_right, bit_add, bytes_to_words, words_to_bytes
from src import pad_message, get_blocks

# Initial Hash Values (H) - 8 32-bit words
H_INIT = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
]

# Round Constants (K) - 64 32-bit words
K = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
]


def sigma_0(x: int) -> int:
    return rotate_right(x, 7) ^ rotate_right(x, 18) ^ shift_right(x, 3)

def sigma_1(x: int) -> int:
    return rotate_right(x, 17) ^ rotate_right(x, 19) ^ shift_right(x, 10)

def SIGMA_0(x: int) -> int:
    return rotate_right(x, 2) ^ rotate_right(x, 13) ^ rotate_right(x, 22)

def SIGMA_1(x: int) -> int:
    return rotate_right(x, 6) ^ rotate_right(x, 11) ^ rotate_right(x, 25)

def ch(x: int, y: int, z: int) -> int:
    return (x & y) ^ ((~x & 0xFFFFFFFF) & z)

def maj(x: int, y: int, z: int) -> int:
    return (x & y) ^ (x & z) ^ (y & z)





def sha_256(message: bytes) -> str:
    padded_message = pad_message(message)
    block_list = get_blocks(padded_message)

    H_current = list(H_INIT)


    for block in block_list:

        word_list = bytes_to_words(block)

        for i in range(48):
            word_list.append(0)     # Extending the word_list to 64 words

        # Words are initialised after this loop from W0 to W63 - MESSAGE EXPANSION
        for i in range(16, 64):
            word_list[i] = bit_add(sigma_1(word_list[i-2]), word_list[i-7], sigma_0(word_list[i-15]), word_list[i-16])

        # initialiing the temporary variables with the current hash state
        [a, b, c, d, e, f, g, h] = H_current

        # 64-ROUND COMPRESSION LOOP
        for i in range(64):
            T1 = bit_add(h, SIGMA_1(e), ch(e, f, g), K[i], word_list[i])
            T2 = bit_add(SIGMA_0(a), maj(a, b, c))
            # updating the variables
            h = g
            g = f
            f = e
            e = bit_add(d, T1)
            d = c
            c = b
            b = a
            a = bit_add(T1, T2)

        # updating the hash states
        H_current[0] = bit_add(H_current[0], a)
        H_current[1] = bit_add(H_current[1], b)
        H_current[2] = bit_add(H_current[2], c)
        H_current[3] = bit_add(H_current[3], d)
        H_current[4] = bit_add(H_current[4], e)
        H_current[5] = bit_add(H_current[5], f)
        H_current[6] = bit_add(H_current[6], g)
        H_current[7] = bit_add(H_current[7], h)

    digest_bytes = words_to_bytes(H_current).hex()
    return digest_bytes
