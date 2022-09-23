import pickle
from PIL import Image, ImageOps
import numpy as np
batches = [
    '../../batch/data_batch_1',
    '../../batch/data_batch_2',
    '../../batch/data_batch_3',
    '../../batch/data_batch_4',
    '../../batch/data_batch_5'
    ]

generated_labels = {
    0: 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
    9: 0
}
scanning = True


def unpickle(file):
    with open(file, 'rb') as fo:
        unpickled = pickle.load(fo, encoding='bytes')
    return unpickled

def is_over():
    for _key, value in generated_labels.items():
        if value < 100:
            return False
    return True

with open('inputs.h', 'w') as f:   
    
    count = 0
    for batch in batches:
        if not scanning :
            break
        data = unpickle(batch)
        filenames = data[b'filenames']
        labels = data[b'labels']
        data = data[b'data']
        for x, row in enumerate(data):
            label = labels[x]
            arrstr = np.char.mod('%i',row)
            current_num = generated_labels[label]
            if current_num == 100:
                continue
            f.write("#define IMG_DATA{}".format(count+1) + " {")
            f.write(",".join(arrstr) )
            f.write("}\n\n") 
            generated_labels[label] = current_num + 1
            if is_over():
                scanning = False
                break
            count+=1
        break
    
    f.write("#define IMG_VECTOR {")
    for i in range(1000):
        if( i > 0):
            f.write(",")
        f.write("IMG_DATA{}".format(i+1))
        
    f.write("}\n\n")