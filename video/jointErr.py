import numpy as np
def jointErr(pred, groundTruth):
#pred= np.asarray([[-4,5,7],[8,9,0]])
#groundTruth =np.asarray([[1,2,3], [10,10,3]])
    N = pred.shape[0]
    dim = pred.shape[1]
    N_joint = dim/3
    diff = np.power((pred - groundTruth), 2)
    errVec = np.zeros(shape=[N, N_joint])
    for i in range(0, N_joint):
        temp = diff[:, i*3:(i+1)*3]
        errVec[:,i] = np.sqrt(np.sum(temp, axis = 1))
    err = np.sum(errVec, axis =1)/N_joint

    return err, errVec
