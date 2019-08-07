import time


def main():
    # 1 means line buffering
    f = open("click.log", 'w', buffering=1)
    while True:
        time.sleep(1)
        f.write("c 800 600\n")

    f.close()


if __name__ == "__main__":
    main()
