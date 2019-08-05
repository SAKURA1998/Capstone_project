import pyautogui
import time
import random


def mouse():
    # sleep 3s
    #time.sleep(3)

    # initialization
    width, height = pyautogui.size()
    print(width)
    print(height)
    center_w = width // 2
    center_h = height // 2
    right = width // 4 * 3
    left = width // 4 * 1

    # reset mouse to the center
    pyautogui.moveTo(center_w, center_h)

    # drag
    pyautogui.dragTo(right, center_h, button='left')


def keyboard():
    """
    2048 Demo
    """
    time.sleep(3)
    print('start')
    pyautogui.press('left')
    #time.sleep(1)
    pyautogui.press('right')
    #time.sleep(1)
    pyautogui.press('up')
    #time.sleep(1)
    pyautogui.press('down')


def random2048():
    time.sleep(3)
    buttons = ['left', 'right', 'up', 'down']
    for i in range(100):
        key = random.choice(buttons)
        pyautogui.press(key)
    

if __name__=="__main__":
    pyautogui.PAUSE = 0.5
    #keyboard()
    random2048()
