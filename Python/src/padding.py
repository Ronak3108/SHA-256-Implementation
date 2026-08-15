# THIS FILE CONTAINS THE PRE-PROCESSING OR PADDING OF DATA INTO CHUNKS OF 512 BITS BEFORE THE ACTUAL ALGORITHM OF SHA-256.

def pad_message(message: bytes) -> bytes:
    bit_len = len(message)*8
    padded = message

    padded += b"\x80"
    zero_bytes_count = (56 - (len(message) + 1) % 64) % 64
    padded_zeros = b"\x00" * zero_bytes_count
    padded += padded_zeros
    len_bytes = bit_len.to_bytes(8, byteorder='big')
    padded += len_bytes

    return padded

def get_blocks(padded_data: bytes) -> list[bytes]:
    block_list = [padded_data[i:i+64] for i in range(0, len(padded_data), 64)]
    return block_list
