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
    if action == "c":  # click
        x = int(splits[1])
        y = int(splits[2])
        pyautogui.click(x=x, y=y)
    elif action == "s":  # slide
        direction = splits[1]
        if direction in ['left', 'right', 'up', 'down']:
            pyautogui.press(direction)
        else:
            print("undefined direction " + direction)
    else:
        print("undefined action " + action)


def main():
    logfile = open("click.log", "r")
    loglines = follow(logfile)
    for line in loglines:
        line = line.strip()
        print(line)
        parse_line(line)


if __name__ == '__main__':
    main()
