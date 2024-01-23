import re, os, time, random, sys
import baidu_translate

# 遍历指定目录下所有以.(swift, h, m)结尾的文件
def find_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            print(file)
            print(root)
            if file.endswith(".swift") or file.endswith(".h") or file.endswith(".m"):
                if any(ignore_file in root for ignore_file in ignore_files):
                        continue
                yield os.path.join(root, file)

# 匹配中文注释的正则表达式
pattern = r"//[^\n]*?[\u4e00-\u9fa5]+[^\n]*"
pattern1 = r"/\*\*([\s\S]*?)\*/"

# 忽略不用处理的中文注释文件夹
ignore_files = []
# 忽略国际化文件中的中文注释
ignore_patterns = ["LocalizedString", "NSLocalizedString", "localized"]

# 遍历所有.swift文件并匹配中文注释
def find_chinese_comments(directory: str, from_lan: str, to_lan: str):
    print(directory)
    for file_path in find_files(directory):
        print(f'file_path == {file_path}')
        with open(file_path, "r", encoding="utf-8") as file:
            content = file.read()
            matches = re.findall(pattern, content)
            matches += re.findall(pattern1, content)

            if matches:
                print(f"在文件 {file_path} 中找到以下中文注释：")
                for match in matches:
                    # 忽略国际化文件中的中文注释
                    if any(ignore_pattern in match for ignore_pattern in ignore_patterns):
                        continue
                    # 判断是否包含中文
                    if _contains_chinese(match):
                        print(f'match == {match}')
                        translates = baidu_translate.translate(match, from_lan, to_lan)
                        for item in translates:
                            src = item["src"]
                            dst = str(item["dst"])
                            dst = dst.replace("*", "* ").replace("//", "// ")
                            content = content.replace(src, dst)
                        time.sleep(random.randint(1, 3))

            # 用新的content写回原文件
            with open(file_path, "w", encoding="utf-8") as file:
                file.write(content)
                file.close()

def _contains_chinese(text):
    pattern = re.compile(r'[\u4e00-\u9fa5]')
    match = re.search(pattern, text)
    return match is not None

if __name__ == '__main__':
    # 获取所有的命令行参数
    arguments = sys.argv
    file_path = arguments[1]
    filter_file = arguments[2]
    filter_text = arguments[3]
    from_lan = arguments[4]
    to_lan = arguments[5]
    
    if len(filter_file) > 0:
        ignore_files.append(filter_file)

    if len(filter_text) > 0:
        ignore_patterns.append(filter_text)
        
    for arg in arguments:
        print(arg)

    # 调用示例
    find_chinese_comments(file_path, from_lan, to_lan)
