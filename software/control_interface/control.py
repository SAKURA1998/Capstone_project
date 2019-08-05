import time
import pyautogui


def follow(thefile):
    thefile.seek(0, 2)
    while True:
        line = thefile.readline()
        if not line:
            time.sleep(0.1)
            continue
        yield line


def parse_line(line):
    splits = line.split(" ")
    action = splits[0]
    x = int(splits[1])
    y = int(splits[2])
    if action == "c":  # click
        pyautogui.click(x=x, y=y)


def main():
    logfile = open("/Users/jasonqsy/Desktop/click.log", "r")
    loglines = follow(logfile)
    for line in loglines:
        line = line.strip()
        print(line)
        parse_line(line)


if __name__ == '__main__':
    main()
