# THIS FILE CONTAINS THE HELPER FUNCTIONS LIKE LEFT & RIGHT ROTATION, SHIFTS ETC THAT ARE REQUIRED FOR THE IMPLEMENTATION OF SHA-256.

def rotate_right(x: int, n: int) -> int:
    return ((x >> (n % 32)) | (x << ((32 - n) % 32))) & 0xFFFFFFFF

def rotate_left(x: int, n: int) -> int:
    return ((x << (n % 32)) | (x >> ((32 - n) % 32))) & 0xFFFFFFFF

def shift_right(x: int, n: int) -> int:
    return ((x >> (n % 32)) & 0xFFFFFFFF)

def shift_left(x: int, n: int) -> int:
    return ((x << (n % 32)) & 0xFFFFFFFF)

def bit_add(*args) -> int:
    sum = 0
    for i in args:
        sum += i
    return (sum & 0xFFFFFFFF)

def bytes_to_words(data: bytes) -> list[int]:
    if len(data) % 4 != 0:
        raise ValueError("The number of bytes, bytes_to_words function has recieved is not a multiple of 4.")
    word_list = [
        int.from_bytes(data[i:i+4], byteorder='big') 
        for i in range(0, len(data), 4)
    ]
    return word_list

def words_to_bytes(words: list[int]) -> bytes:
    byte_list = [(word & 0xFFFFFFFF).to_bytes(4, byteorder='big') for word in words]
    byte_stream = b"".join(byte_list)
    return bytes(byte_stream)

