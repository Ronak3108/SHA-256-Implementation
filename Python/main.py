import argparse
import sys
from src.sha256 import sha_256


def main():
    parser = argparse.ArgumentParser(description="THe Command Lime interface for using the SHA-256 algorithm.")

    parser.add_argument("-s", "--str", type=str, help="Pass a string as an argument to the SHA-256 Algorithm.")
    parser.add_argument("-f", "--file", type=str, help="Pass a File as an Argument to the SHA-256 Algorithm.")

    args = parser.parse_args()

    if (args.str):
        arg = args.str
        digest = sha_256(arg.encode('utf-8'))
        print(f"HASH: {digest}")
    elif (args.file):
        arg = args.file
        try:
            with open(arg, 'rb') as f:
                digest = sha_256(f.read())
                print(f"HASH: {digest}")
        except:
            print(f"Error: File '{args.file}' not found.")
            sys.exit(1)
    else:
        parser.print_help()




if __name__ == "__main__":
    main()


