def getEnitites(data):
    res = {}
    for row in data:
        if (row == "#"):
            break
        arr = row.split("@")
        res[arr[0]] = arr[1]
    return res
# Hàm load dữ liệu từ file
def loadFile(filePath):
    res = []
    try:
        with open(filePath, 'r') as f:
            for line in f:
                s = line
                if line.endswith('\n'):
                    s = line.replace("\n", "")
                res.append(s)
        return res
    except IOError:
        print("Could not load file")
        
def main():
    data_read_f1 = loadFile("input1_2.txt")
    entities = getEnitites(data_read_f1)
    print(entities)

main()