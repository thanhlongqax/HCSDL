import itertools
##Bai 1________

def getEnitites(data):
    entities = []
    for line in data:
        if line.startswith('Entity'):
            _, entity_name = line.split()
            entities.append(entity_name)
    return entities

def getRelationships(data):
    relationships = []
    for line in data:
        if line.startswith('Relationship'):
            _, rel_name = line.split()
            relationships.append(rel_name)
    return relationships

def convert(entities, relationships):
    for tmp in relationships:
        arr = tmp.split(",")
        attr = ""
        
        if(len(arr) > 4):
            for i in range(3, len(arr)):
                attr = attr + arr[i] + ","
        set_write_f1(arr[0], arr[1], arr[2], attr, entities)
data_write_f1 = {}

def data_writeFile1(output_filename, data_write_f1):
    with open(output_filename, 'w') as f:
        for line in data_write_f1:
            f.write(line + '\n')
        print("Ghi file thành công")
##Bai 2 _________
#hàm lấy các phụ thuộc hàm
def dependency(data):
    left = []
    right = []
    lst = data[1].split(",")
    index = 0
    for item in lst:
        arr = item.split("->")
        left.append(arr[0])
        right.append(arr[1])
    return left, right

#Hàm lấy ra lược đồ cơ sở dữ  liệu
def dbs(data): 
    return data[0]

#Hai hàm phụ trợ 
def notDuplicate(s, tmp):
    arr = [i for i in tmp]
    for item in arr:
        if not s.__contains__(item):
            s = s + item
    return s

def include(s, tmp):
    tmp = [i for i in tmp]
    for item in tmp:
        if not s.__contains__(item):
            return False
    return True

    
#Hàm tìm bao đóng
def findwrap(s, dbs, dependency):
    visited = [False for i in range(len(dependency[0]))]
    prev = s
    
    while len(s) < dbs:
        i = 0
        while i < len(dependency[0]):  # Điều chỉnh lỗi cú pháp ở đây
            if include(s, dependency[0][i]) and not visited[i]:
                visited[i] = True 
                s = notDuplicate(s, dependency[1][i])
                i = 0
            i = i + 1
        if prev == s:
            return s
        prev = s
    return s

    
# Hàm tìm UR và UL
def findULR(dependency, index):
    s =""
    for i in dependency [index]:
        s = notDuplicate(s, i)
    return s
   
def findRes(s1, s2):
    s = ""
    for item in s1: 
        if(not include(s2, item)): 
            s += item
    return s
    
#Hàm tìm Li
def findChildAttr(L, num):
    A = [i for i in L]
    t = list(itertools.combinations(A, num))
    k = []
    for item in t:
        s = ""
        for p in item:
            s = s + p
        k.append(s)
    return k
    
# Hàm tìm tất cả các khóa
def findAllKeys(dbs, N, D, L, dependency):
    keys = []
    if(len(findwrap (N, len (dbs), dependency)) == len(dbs)):
        return [N]
    else:
        lst = []
        for i in range(1, len(L)):
            lst.append(findChildAttr(L, i))
        keys = []
        for i in lst:
            for k in i:
                ek = N + k
                wrap = findwrap(ek, len (dbs), dependency)
                len_wrap = len(wrap)
                if(len_wrap == len(dbs)):
                    exist = False
                    for tmp in keys: 
                        if(include(ek, tmp)):
                            exist = True
                    if exist == False: 
                        keys.append(ek)
    return keys
    
    
def loadFile(filePath):
    res = []
    try:
        with open(filePath, 'r') as f:
            for line in f:
                s = line
                if(line.endswith('\n')):
                    s = line.replace("\n", "")
                res.append(s)
        return res
    except IOError:
        print("Không thể đọc file")

def writeFile2(filePath, data1, data2):
    try:
        f = open(filePath, 'w')
        f.write("Bao dong: ")
        f.write(data1 + "\n")
        f.write("Tat ca khoa: ")
        for line in data2:
            if(line == data2[-1]): 
                f.write(line)
            else:
                f.write(line + ",")
        f.close()
        print("Successfully to wrote the file")
    except IOError:
        print("Can not wrote to the file")
        
def main():
    data_read_f1 = loadFile("input1.txt")
    entities = getEnitites(data_read_f1)
    relationships = getRelationships(data_read_f1)
    convert(entities, relationships) 
    writeFile1("output1.txt", data_write_f1)
    
    
    data_read_f2 = loadFile("input2.txt")
    db = dbs(data_read_f2)
    dep = dependency(data_read_f2)
    UL = findULR(dep, 0)
    UR = findULR(dep, 1)
    N = findRes(db, UR)
    D = findRes(UR, UL)
    L = findRes(db, N + D)
    wrapper = findwrap("AD", len(db), dep)
    data_write_f2 = findAllKeys(db, N, D, L, dep) 
    writeFile2("output2.txt", wrapper, data_write_f2)

main()