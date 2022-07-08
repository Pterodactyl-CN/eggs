#!/usr/bin/python
import json
import os
for root, dirs, files in os.walk('.'):
    for f in files:
        # 忽略 .git
        if ".git" in root:
            continue
        # print(os.path.join(root, f))
        # 如果不是 json 结尾
        if not f.endswith(".json"):
            continue
        filePath = os.path.join(root, f)
        # 读内容
        with open(filePath, encoding="utf-8", mode="r") as fileObj:
            filedata = fileObj.read()
        jsonContent = json.loads(filedata)
        # 写内容
        with open(filePath, encoding="utf-8", mode="w") as fileObj:
            fileObj.write(json.dumps(
                jsonContent, indent=4, ensure_ascii=False))
