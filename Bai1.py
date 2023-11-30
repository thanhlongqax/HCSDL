data_write_f1 = {}
#Lấy ra thực thể
def get_entity_attributes(data):
    entity_attributes = {}

    capturing = False
    current_entity = None

    for line in data:
        line = line.strip()

        if line == "@":
            capturing = not capturing
        elif capturing is False:
            entity_info = line.split(':')
            current_entity = entity_info[0].strip()
            attributes = [attr.strip() for attr in entity_info[1].split(',')]
            entity_attributes[current_entity] = attributes

    return entity_attributes

#Lấy ra mối quan hệ thực thể
def getRelationships(data):
    relationships = []
    index = data.index("@") + 1
    for i in range(index , len(data)):
        relationships.append(data[i])
    return relationships

# Hàm lấy ra khóa chính của một thực thể và khóa ngoại của 1 thực thể
def get_keys(ent, f1):
    primary_key = []
    foreign_key = []
    # Check if f1 exists in ent
    if f1 in ent:
        # Iterate through attributes of the entity f1
        for attribute in ent[f1]:
            # Check if the attribute contains '(PK)'
            if '(PK)' in attribute:
                primary_key.append(attribute.split('(PK)')[0].strip())

            # Check if the attribute is not the primary key and contains '(FK)'
            elif primary_key and '(FK)' in attribute:
                foreign_key.append(attribute.split('(FK)')[0].strip())

    return primary_key, foreign_key
#Hàm lấy ra danh định riêng phần của thực thể yếu
def cutdd(attributes):
    return ["pk_" + attr.split("(DD)")[0] for attr in attributes if "(DD)" in attr]
# Hàm lấy ra các thuộc tính của thực thể yếu
def attr_weak(dd):
    attributes = dd[1:]  # Skip the first element (primary key)
    return [attr for attr in attributes if "(DD)" not in attr]



# Hàm chuyển đổi ERD sang mô hình quan hệ
# Chuyển đổi ERD sang mô hình quan hệ
def convert(entities, relationships):
    
    for relationship in relationships:
        # Chuyển mỗi phần tử thành chuỗi và loại bỏ dấu ngoặc nhọn
        relationship_elements = relationship.split(",")
        attr = ""
        if len(relationship_elements) > 4:
            for i in range(3, len(relationship_elements)):
                attr = attr + relationship_elements[i] + ","
        set_write_f1(
            relationship_elements[0].strip(),
            relationship_elements[1].strip(),
            relationship_elements[2].strip(),
            attr.strip(),
            entities
        )
        
def create_many_to_many_table(f1, f2, entities):
    # Check if both entities exist in the dictionary
    if f1 in entities and f2 in entities:
        # Create a table name based on entity names
        table_name = f"{f1}_{f2}"

        # Extract primary keys of both entities with the 'pk_' prefix
        pk_entity_1 = 'pk_' + entities[f1][0].split('(PK)')[0].strip()
        pk_entity_2 = 'pk_' + entities[f2][0].split('(PK)')[0].strip()

        # Create the table structure
        table_structure = [
            pk_entity_1 ,pk_entity_2
        ]
        # Add the table structure to the entities dictionary
        entities[table_name] = table_structure
        return entities
    else:
        print("Error: One or both entities do not exist in the dictionary.")
        return None

# Hàm set_write_f1 được sửa lại để xử lý thuộc tính đặc biệt của primary key
def set_write_f1(f1, f2, relationship, attr, ent):
    if f1 not in data_write_f1:
        data_write_f1[f1] = ent[f1]
    if f2 not in data_write_f1:
        data_write_f1[f2] = ent[f2]
    if relationship == "1-n":
        primary_keys, foreign_keys = get_keys(ent, f1)
        data_write_f1[f2] = data_write_f1.get(f2, '') + [',fk_' + ', '.join(primary_keys)]
    if relationship == "n-n":
        data_write_f1[f1 + f2] = create_many_to_many_table(f1, f2, ent)
    if relationship == "kethua":
        primary_keys, foreign_keys = get_keys(ent, f1)
        data_write_f1[f2] = ['pk_' + ', '.join(primary_keys)] + data_write_f1.get(f2, [])
    if relationship == "phuthuoc":
        primary_keys, foreign_keys = get_keys(ent, f1)
        data_write_f1[f2] = 'pk_' + ','.join(primary_keys + cutdd(data_write_f1[f2]) )  + ','  + ','.join(attr_weak(data_write_f1[f2])) + ',fk_' + '_'.join(primary_keys)




# - Hàm phát sinh quan hệ mới của mối quan hệ n-n:
# def Table_Many_Many(entity_name_1, entity_name_2, attributes, entities):

    
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

# Hàm ghi dữ liệu vào file
def data_writeFile1(entities  ,file_path):
    try:
        with open(file_path, 'w', encoding='utf-8') as file:
            for key, value in data.items():
                if isinstance(value, list):
                    file.write(f'{key}:\n')
                    for item in value:
                        file.write(f'  - {item}\n')
                elif isinstance(value, dict):
                    file.write(f'{key}:\n')
                    for sub_key, sub_value in value.items():
                        file.write(f'  {sub_key}:\n')
                        for sub_item in sub_value:
                            file.write(f'    - {sub_item}\n')
                else:
                    file.write(f'{key}: {value}\n')

        print(f'Data has been written to {file_path} successfully.')
    except Exception as e:
        print(f'Error writing to {file_path}: {e}')

def format_output(output):
    # Bước 1: Loại bỏ dấu ngoặc vuông
    output = str(output).replace('[', '').replace(']', '')

    # Bước 2: Loại bỏ dấu cách thừa và dấu nhấn ','
    output = output.replace(', ', ',').strip()

    # Bước 3: Thay thế dấu ', ' bằng dấu ','
    output = output.replace(', ', ',')

    # Bước 4: Bao quanh mỗi giá trị bằng dấu '
    output = "'{}'".format(output.replace(',', "','"))

    # Bước 5: Loại bỏ dấu nháy đơn
    output = output.replace("'", "")

    return output

##Bai 2 _________

# Main function


        
def main():
    data_read_f1 = loadFile("input1.txt")
    entities =get_entity_attributes(data_read_f1)
    relationships = getRelationships(data_read_f1)
    convert(entities , relationships)
    filePath = 'output.txt'
    print(type(data_write_f1))
    #data_writeFile1(data_write_f1 , filePath)
    for item in data_write_f1.items():
        
        print(item)
main()
