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

def resizeImage(srcfile, new_width=32, new_height=32):
    '''
    Resize and crop a image to desired resolution and return the 
    data as HWC format numpy array.
    srcfile: the source image file path.
    new_width: new desired width.
    new_height: new desired height.
    '''
    pil_image = Image.open(srcfile)
    pil_image = ImageOps.fit(pil_image, (new_width, new_height), Image.ANTIALIAS)
    pil_image_rgb = pil_image.convert('RGB')
    return np.asarray(pil_image_rgb).flatten()


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
            # if count > 0:
            #     f.write(",")
            f.write(",".join(arrstr) )
            f.write("}\n\n") 
            generated_labels[label] = current_num + 1
            if is_over():
                scanning = False
                break
            count+=1
        # print(len(data[b'data'][0]))
        break
        # print(data.keys())
    
    f.write("#define IMG_VECTOR {")
    for i in range(1000):
        if( i > 0):
            f.write(",")
        f.write("IMG_DATA{}".format(i+1))
        
    f.write("}\n\n")