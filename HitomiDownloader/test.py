import requests
import json
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import os

driver = None

def StartSelenium():
    options = webdriver.ChromeOptions()
    options.add_experimental_option("detach", True)
    #options.add_argument('headless')
    global driver
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

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
        print(ImageLink)
        return ImageLink
    except Exception as e:
        os.system("osascript -e \'Tell application \"System Events\" to display dialog \"Connection failure: " + str(e).replace("Message: ", "") + "\" with title \"Hitomi Downloader\"\'")
        print("An error occurred:", e)
        return None
    finally:
        if IsLast:
            os.system("osascript -e \'Tell application \"System Events\" to display dialog \"Finished Download\" with title \"Hitomi Downloader\"\'")
            driver.quit()

def CountPics(id):
    url = "https://ltn.hitomi.la/galleries/"+id+".js"

    response = requests.get(url, {"User-Agent" : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'})
    if response.status_code == 200:
        content = response.text

        print(content)
        imageCount = content.count(".png") if content.count(".jpg") == 0 else content.count(".jpg")

        if imageCount == 0:
            print("Try connecting to VPN because we couldn't fetch any data!")

        print(f'Successfully fetched image count: {imageCount}')

        return imageCount
    else:
        print(f'Failed to fetch image count. Status code: {response.status_code}')
        return None

def DownloadImage(targetUrl, REFERAL_LINK, parent, name):
    header = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', 'Referer': REFERAL_LINK}
    with requests.get(targetUrl, headers=header, stream=True) as r:
        r.raise_for_status()
        if not os.path.exists('Saved/' + parent):
            os.makedirs('Saved/' + parent)
        with open('Saved/' + parent + '/'+str(name) + '.webp', 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
    print("Downloaded " + targetUrl)

def jsonfuck():
    js_object = """var galleryinfo = {"video":null,"files":[{"hash":"3be85da93ff6141a9b53b1a2cd63a430fbce25fb47bee006d164f7484f688e9b","hasavif":1,"width":1438,"height":2000,"name":"01.jpg","haswebp":1},{"hash":"3bc22ece53da050114b3eaa205376f26391a26f111a25d2d087ff90b123cc416","hasavif":1,"width":1438,"height":2000,"name":"02.jpg","haswebp":1},{"haswebp":1,"width":1438,"height":2000,"name":"03.jpg","hasavif":1,"hash":"73ae9bceb0dcbaec69166e363aedf084101ff80cab5160fcf401eba64f234342"},{"haswebp":1,"width":1438,"height":2000,"name":"04.jpg","hasavif":1,"hash":"9102957be0adaec579db1bc51ca3ea62eaa8671ec9c8d29ea7426f2da23cdeda"},{"hasavif":1,"hash":"61433389c357b9e9a6225d6da5742b3f19a41328a011bfd7d0b4f4dc2bb87de6","width":1438,"height":2000,"name":"05.jpg","haswebp":1},{"hash":"6833451e2c2aa63ddd683951f70225a8b441a9c1b699eca1e48b8e2befd4b20e","hasavif":1,"height":2000,"width":1438,"name":"06.jpg","haswebp":1},{"haswebp":1,"height":2000,"name":"07.jpg","width":1438,"hash":"b01e39a66f7e7bf6ab08ed6c04c27ce6f2554d0ce469550a51306d9a50f93fa1","hasavif":1},{"haswebp":1,"height":2000,"name":"08.jpg","width":1438,"hasavif":1,"hash":"3aa1d70fe2c8fbf3f428e67718d25ff87ca7aacef0610513dbd476a08e84f39b"},{"haswebp":1,"hasavif":1,"hash":"29eaba0b9384af083a8ac1bae3b642b993b2dd709052114c57fd547fb4062925","height":2000,"width":1438,"name":"09.jpg"},{"haswebp":1,"hasavif":1,"hash":"c9f3c433b676f3f2abdff4b2d075cddad81ba9967235682b0083a347b917c7b6","width":1438,"height":2000,"name":"10.jpg"},{"haswebp":1,"name":"11.jpg","height":2000,"width":1438,"hasavif":1,"hash":"dd95b3a6741d8142bbe0e3474fe7d111ce4b50b88de869c3c70926baa0f15836"},{"haswebp":1,"hasavif":1,"hash":"8487293c2280f2f1823ac769aa60862dd5653920dce258abdf013d23b57b10d0","name":"12.jpg","height":2000,"width":1438},{"haswebp":1,"hasavif":1,"hash":"6115efe80fefba174537809077a4bd608310eb848ed2650b17c6d44d0296a484","name":"13.jpg","height":2000,"width":1438},{"haswebp":1,"hash":"da78e8e88d79d1ced253f03dc53ed07fcae701bb7675886c95b5bb767b5728cb","hasavif":1,"height":2000,"width":1438,"name":"14.jpg"},{"haswebp":1,"hash":"96abbcadcfaa1ef21f942d35f1c1d73f202546df8aeb67566041a37ee0e69697","hasavif":1,"height":2000,"name":"15.jpg","width":1438},{"haswebp":1,"hasavif":1,"hash":"b758b7c30c2f52c6af1eefe8af139eee35b836cb8ae258884c3f3fe66be8750a","height":2000,"name":"16.jpg","width":1438},{"hasavif":1,"hash":"deaf71e81e35361dbfe04ac547371b297c03a50f658c070664d4b61d312b2c9b","name":"17.jpg","height":2000,"width":1438,"haswebp":1},{"haswebp":1,"height":2000,"width":1438,"name":"18.jpg","hasavif":1,"hash":"dcf9121a4e16652a33f87c6a738e6ad0c610f7ffbe4d73f3718008d105a8ee9d"},{"width":1438,"height":2000,"name":"19.jpg","hasavif":1,"hash":"40fd3b43d322db38cfeb162e1afb1176e48aa4198de80c244b6d3c487c0bf76a","haswebp":1},{"hash":"ab7e9c957f9a57d5ec5142277f61cd26f77b77215dc177c7f7de2531044ae865","hasavif":1,"height":2000,"width":1438,"name":"20.jpg","haswebp":1},{"hasavif":1,"hash":"12e7eb986ded7b2ca0877bf3b91851ecef7b5af9f984cf2b39a8e0677d0bee24","width":1438,"height":2000,"name":"21.jpg","haswebp":1},{"hash":"679e495adc55a2346111d44247f3a5f5464c943fa1aecf069495f5750ab210ec","hasavif":1,"height":2000,"name":"22.jpg","width":1438,"haswebp":1},{"haswebp":1,"hash":"cea01788dbd2fd6833b3155b26315ec7a1b6d0c33da5ef00e52d45ab701d87af","hasavif":1,"height":2000,"name":"23.jpg","width":1438},{"haswebp":1,"height":2000,"width":1438,"name":"24.jpg","hash":"a42c1989193569c998bf15a5fb84f12b76b3dd71028bf9a04e265178e7303064","hasavif":1},{"haswebp":1,"height":2000,"width":1438,"name":"25.jpg","hash":"e35e536d91f55fac55cd9e195712653d9d834fe8787cb1448824046ece31520b","hasavif":1},{"haswebp":1,"height":2000,"width":1438,"name":"26.jpg","hash":"8e94283930548dc107656b958738f552317ff510ec5b0db5ef06a05b43731f45","hasavif":1},{"haswebp":1,"hash":"61aca332248957913d10983b0c814bee7d979dfae3af61f9f1de56a0e3c0948f","hasavif":1,"height":2000,"name":"27.jpg","width":1438},{"hasavif":1,"hash":"9fc5e7531d1b23d270dd024049523ec3df131e316a6ef05fa496baf03778562f","name":"28.jpg","height":2000,"width":1438,"haswebp":1},{"hasavif":1,"hash":"f3d0e65b41917a9a5ebb647756ee99ecaefa8fe6552b3c2fe7360757558ac53d","width":1438,"height":2000,"name":"29.jpg","haswebp":1},{"height":2000,"width":1438,"name":"30.jpg","hasavif":1,"hash":"a6f557c40e47856014f4e3f73dd6f645beaf90baa92093a858a5a4e1d5743200","haswebp":1},{"haswebp":1,"hasavif":1,"hash":"5afdd34c5d71b46c63cbcfbae7d317140d819a2949785641d3be72af203e224f","height":2000,"width":1438,"name":"31.jpg"},{"width":1438,"height":2000,"name":"32.jpg","hash":"d4984437c492eda70e6d7af4c85b301d54c8362623603452f3653a7c349448e9","hasavif":1,"haswebp":1},{"haswebp":1,"width":1438,"height":2000,"name":"33.jpg","hash":"faea093fd839460b37a798148e8500541fb174c6187efd5304e012eca31da49f","hasavif":1},{"haswebp":1,"width":1438,"height":2000,"name":"34.jpg","hash":"e21575a2ab73a6ad081a34f6e168c6d8bdf0d51ffc886c3353a8461edd54c531","hasavif":1},{"haswebp":1,"hash":"cd7f349d4270a49fefdb930c37439197e75e8a712146657696c77848c48eb44c","hasavif":1,"height":2000,"name":"35.jpg","width":1438},{"hasavif":1,"hash":"ddda8fdb3ccf8e93345997e2d5b021fee676f2668517b3a98800c03496742abf","name":"36.jpg","height":2000,"width":1438,"haswebp":1},{"haswebp":1,"hasavif":1,"hash":"cdc1af9dd6ad8ebb48656a5ec2bfbe256a701285836682b3c3cbf459693d94aa","width":1438,"height":2000,"name":"37.jpg"},{"haswebp":1,"width":1438,"height":2000,"name":"38.jpg","hasavif":1,"hash":"1347e25b536d53c6f10a2183f118212dbaa00a5fd0d6d9567a2ebf93dbd71e8f"},{"height":2000,"width":1438,"name":"39.jpg","hash":"fec20a1a81d3623e7f23f21704f4c381429cdd5bedd2444a87bb81d9059fc9b6","hasavif":1,"haswebp":1},{"haswebp":1,"height":2000,"width":1438,"name":"40.jpg","hasavif":1,"hash":"36b4bd5b6fcd905ca004c43a65764505dd72e6ad5af8a411052d13711fa38c39"},{"height":2000,"name":"41.jpg","width":1438,"hash":"e3f823eba73adf308ed5f1eefb77a5a7624980e4e3d7f0187e5fe2fc9b58cf33","hasavif":1,"haswebp":1},{"hasavif":1,"hash":"0e97d90fe7caee104d1e4e1e86850a69f7bc9aa03ed4a780922d7efefbec16c6","height":2000,"width":1438,"name":"42.jpg","haswebp":1}],"id":"2459065","galleryurl":"/doujinshi/papakatsu-bitch-no-atashi-ra-ga-anta-no-otouto-o-katte-mesuiki-yarichin-kun-ni-shite-kawaigatte-ageru-한국어-2459065.html","parodys":[{"parody":"original","url":"/series/original-all.html"}],"date":"2023-02-07 02:07:00-06","scene_indexes":[],"related":[1347544,2439714,1797045,1497826,1485447],"language_url":"/index-korean.html","groups":[{"group":"tiramisu tart","url":"/group/tiramisu%20tart-all.html"}],"type":"doujinshi","characters":null,"language_localname":"한국어","tags":[{"female":"1","male":"","url":"/tag/female%3Aanal-all.html","tag":"anal"},{"url":"/tag/female%3Abig%20breasts-all.html","tag":"big breasts","male":"","female":"1"},{"url":"/tag/female%3Adark%20skin-all.html","tag":"dark skin","male":"","female":"1"},{"female":"1","male":"","url":"/tag/female%3Afemdom-all.html","tag":"femdom"},{"male":"","female":"1","url":"/tag/female%3Agyaru-all.html","tag":"gyaru"},{"tag":"mouth mask","url":"/tag/female%3Amouth%20mask-all.html","male":"","female":"1"},{"tag":"schoolgirl uniform","url":"/tag/female%3Aschoolgirl%20uniform-all.html","female":"1","male":""},{"url":"/tag/ffm%20threesome-all.html","tag":"ffm threesome"},{"url":"/tag/group-all.html","tag":"group"},{"tag":"prostitution","url":"/tag/male%3Aprostitution-all.html","male":"1","female":""},{"tag":"shota","url":"/tag/male%3Ashota-all.html","male":"1","female":""},{"tag":"sole male","url":"/tag/male%3Asole%20male-all.html","male":"1","female":""}],"artists":[{"artist":"kazuhiro","url":"/artist/kazuhiro-all.html"}],"languages":[{"galleryid":"2323624","name":"english","url":"/galleries/2323624.html","language_localname":"English"},{"url":"/galleries/2350963.html","language_localname":"Português","name":"portuguese","galleryid":"2350963"},{"url":"/galleries/2485381.html","language_localname":"Русский","name":"russian","galleryid":"2485381"},{"galleryid":"2459065","url":"/galleries/2459065.html","language_localname":"한국어","name":"korean"},{"url":"/galleries/2389651.html","language_localname":"中文","name":"chinese","galleryid":"2389651"},{"language_localname":"日本語","url":"/galleries/2280277.html","name":"japanese","galleryid":"2280277"}],"language":"korean","japanese_title":null,"videofilename":null,"title":"Papakatsu Bitch no Atashi-ra ga Anta no Otouto o Katte Mesuiki Yarichin-kun ni Shite Kawaigatte Ageru"}"""

    # Extract the JSON part from the JavaScript object
    json_start = js_object.index("{")
    json_end = js_object.rindex("}") + 1
    json_str = js_object[json_start:json_end]

    # Load the JSON data into a Python dictionary
    data = json.loads(json_str)

    # Extract hash values from the "files" array
    hash_values = [file_info["hash"] for file_info in data["files"]]

    for hash_value in hash_values:
        print(hash_value)

def testdownl():
    refurl = "https://hitomi.la/reader/2459065.html#7"
    FetchImageUrl(refurl)

def fuckhitomi(id):
    picCount = CountPics(id)
    for i in range(picCount):
        referalUrl = "https://hitomi.la/reader/" + id + ".html#" + str(i + 1)
        ImageUrl = FetchImageUrl(referalUrl)
        if ImageUrl != None and i != range(picCount):
            DownloadImage(ImageUrl, referalUrl, id, i + 1)
        elif i + 1 == picCount:
            DownloadImage(ImageUrl, referalUrl, id, i + 1, True)

fuckhitomi("2642889")