# -*- coding: utf-8 -*-

# This code shows an example of text translation from English to Simplified-Chinese.
# This code runs on Python 2.7.x and Python 3.x.
# You may install `requests` to run this code: pip install requests
# Please refer to `https://api.fanyi.baidu.com/doc/21` for complete api document

import requests
import random
import json
from hashlib import md5

# Set your own appid/appkey.
appid = ''
appkey = ''

endpoint = 'http://api.fanyi.baidu.com'
path = '/api/trans/vip/translate'
url = endpoint + path


# Generate salt and sign
def _make_md5(s, encoding='utf-8'):
    return md5(s.encode(encoding)).hexdigest()


def translate(word: str, from_lang: str = "auto", to_lang: str = "auto"):
    salt = random.randint(32768, 65536)
    sign = _make_md5(appid + word + str(salt) + appkey)

    # Build request
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    payload = {'appid': appid, 'q': word, 'from': from_lang, 'to': to_lang, 'salt': salt, 'sign': sign}

    # Send request
    r = requests.post(url, params=payload, headers=headers).json()

    # Show response
    print(r)
    result = r['trans_result']
    return result


if __name__ == '__main__':
    translate("//  Created by 中文 on 2022/8/30.")
