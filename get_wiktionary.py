with open("Wiktionary/en-ro-enwiktionary.txt", encoding="utf-8") as file:
    data = file.readlines()

clean_data = []

with open("en-ro.txt2", "w", encoding="utf-8") as f:
    for item in data:
        if "#" in item:
            pass
        else:
            item = item.replace("\n","")
            z = item.split("::")
            if len(z[1]) == 0:
                pass
            else:
                for i in z[1].split(","):
                    s = "{} {}".format(z[0].split('{')[0].strip(),i.split('{')[0].strip())
                    if len(s.split()) != 2:
                        pass
                    else:
                        f.write(s)
                        f.write('\n')
    # print(clean_data)
    # print(len(clean_data))

with open("en-ro.txt2", "r", encoding="utf-8") as er:
    data = er.readlines()
    with open("ro-en.txt2", "w", encoding="utf-8") as re:
        for item in data:
            it = item.split()
            print(it)
            re.write("{} {}".format(it[1].strip(), it[0].strip()))
            re.write('\n')