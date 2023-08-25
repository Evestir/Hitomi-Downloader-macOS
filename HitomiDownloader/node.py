import requests
import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from requests.exceptions import HTTPError
from time import sleep
import json
import threading
import sys
from pathlib import Path
import datetime

driver = None
CurJs = "sams"

def CountPics(id):
    global CurJs

    if id not in CurJs:
        print("Downloading New Json metadata for this manga")

        url = "https://ltn.hitomi.la/galleries/"+id+".js"
        response = requests.get(url, {"User-Agent" : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'})
        if response.status_code != 200:
            print(f'Failed to fetch image count. Status code: {response.status_code}')
            return None
        CurJs = response.text

    #print(content)
    imageCount = CurJs.count(".png") + CurJs.count(".jpg")

    if imageCount == 0:
        print("Try connecting to VPN because we couldn't fetch any data!")

    print(f'Successfully fetched image count: {imageCount}')

    return imageCount        

def FetchName(id):
    global CurJs

    if id not in CurJs:
        print("Downloading New Json metadata for this manga")

        url = "https://ltn.hitomi.la/galleries/"+id+".js"
        response = requests.get(url, {"User-Agent" : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'})
        if response.status_code != 200:
            print(f'Failed to fetch name. Status code: {response.status_code}')
            return None
        CurJs = response.text

    json_start = CurJs.index("{")
    json_end = CurJs.rindex("}") + 1
    json_str = CurJs[json_start:json_end]

    # Load the JSON data into a Python dictionary
    data = json.loads(json_str)
    name = data["title"]

    print(f'Successfully fetched manga name: {name}')

    return name
   

def StartSelenium():
    options = webdriver.ChromeOptions()
    options.add_experimental_option("detach", True)
    options.add_argument('headless')
    global driver
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

def StopSelenium():
    global driver
    driver.quit()

def FetchImageUrl(targetUrl, IsLast = False):
    if driver == None:
        StartSelenium()
    try:
    # Connect to hitomi.la
        driver.get(targetUrl)
    # Wait until the page Initialize
        ImageEle = WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.XPATH, """//*[@id="comicImages"]/picture/img""")))

    # Find Image Url
        ImageLink = ImageEle.get_attribute("src")
        #print(ImageLink)
        return ImageLink
    except Exception as e:
        os.system("osascript -e \'Tell application \"System Events\" to display dialog \"Connection failure: " + str(e).replace("Message: ", "") + "\" with title \"Hitomi Downloader\"\'")
        print("An error occurred:", e)
        return None

def DownloadImage(targetUrl, REFERAL_LINK, parent, name, Mname):
    header = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', 'Referer': REFERAL_LINK}
    for i in range(4):
        try:
            with requests.get(targetUrl, headers=header, stream=True) as r:
                r.raise_for_status()
                pathh = pictures_directory = os.path.join(os.path.expanduser("~"), "Pictures") + "/Hitomi/" + parent
                if not os.path.exists(pathh):
                    os.makedirs(pathh)
                with open(pathh + '/' + str(name) + '.webp', 'wb') as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
            break
        except HTTPError as e:
            sleep(i)
            if i == 3:
                os.system("osascript -e \'Tell application \"System Events\" to display dialog \"Connection failure: " + str(e) + "\" with title \"Hitomi Downloader\"\'")
    print("Downloaded " + targetUrl)

class Gallary:
    def __init__(self, name, id, date, count, coverImage):
        self._name = name
        self._id = id
        self._date = date
        self._count = count
        self._coverImage = coverImage
    
    def toJson(self):
        return {
            "name": self._name,
            "id": self._id,
            "date": self._date,
            "totalPages": self._count,
            "coverImage": self._coverImage
        }

def BackgroundDownload(id, Mname, picCount):
    for i in range(picCount):
        # Skip downloading cover image
        referalUrl = "https://hitomi.la/reader/" + id + ".html#" + str(i + 1)
        ImageUrl = FetchImageUrl(referalUrl)
        if ImageUrl != None and i + 1 != picCount:
            DownloadImage(ImageUrl, referalUrl, id, i + 1, Mname)
        elif i + 1 == picCount:
            DownloadImage(ImageUrl, referalUrl, id, i + 1, Mname)
            os.system("osascript -e \'Tell application \"System Events\" to display dialog \"Finished Downloading: " + Mname + "\" with title \"Hitomi Downloader\"\'")
            StopSelenium()

    

def Download(id):
    Mname = FetchName(id)
    picCount = CountPics(id)
    parentPath = os.path.join(os.path.expanduser("~"), "Pictures") + "/Hitomi/" + id
    coverImgPath = parentPath + "/1.webp"

    today = datetime.date.today()
    formatted_date = today.strftime("%B %d")

    infoJson = Gallary(Mname, id, formatted_date, picCount, coverImgPath).toJson()
    if not os.path.exists(parentPath):
        os.makedirs(parentPath)
    with open(os.path.join(os.path.expanduser("~"), "Pictures") + "/Hitomi/" + id + "/gallery.json", "w") as json_file:
        json_file.write(json.dumps(infoJson, indent=4))

    backgroundWorker = threading.Thread(target=BackgroundDownload, args=(id, Mname, picCount))
    backgroundWorker.start()

    backgroundWorker.join()
    
Download(sys.argv[1])