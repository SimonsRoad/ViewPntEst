import pandas
import math
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from keras.layers import Dropout
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error
import h5py
import numpy as np
from sklearn.preprocessing import MinMaxScaler
#import matplotlib.pyplot as plt

nb_epoch = 1000
print(chr(27)+"[2J")
np.random.seed(7)
subj_trn = [260, 968, 1336, 2044]
subj_tst = [2045, 2268]
dim = 32
look_back = 100

def create_dataset(dataset, look_back=1):
    dataX, dataY = [], []
    N = dataset.shape[0]
    for i in range(N - look_back-1):
        a = dataset[i:(i+look_back), :]
        dataX.append(a)
        dataY.append(dataset[i + look_back, :])
    return np.array(dataX), np.array(dataY)


f = h5py.File('./data/video.h5')
data = f.get(f.keys()[0])
data = np.array(data)
N_trn = round(data.shape[0]*0.8)
print('N_trn: ', N_trn)
print('data.shape', data.shape)
print('-'*100)


pre_i = 0
trainX = []
trainY = []
# normalize the dataset
scaler = MinMaxScaler(feature_range = (0, 1))
dataset = scaler.fit_transform(data)

for i,j in enumerate(subj_trn):
    ind_s = 0
    ind_e = subj_trn[i]
    if i != 0:
        ind_s = subj_trn[i-1]
    X, Y = create_dataset(dataset[ind_s:ind_e,:], look_back)
    trainX.extend(X)
    



trainX, trainY = create_dataset(dataset[0:N_trn,:], look_back)
testX, testY = create_dataset(dataset[N_trn:,:], look_back)

trainX = np.asarray(trainX)
trainY = np.asarray(trainY)

testX = np.asarray(testX)
testY = np.asarray(testY)
print(testY.shape)
print(trainX.shape)
print('-'*100)

model = Sequential()
model.add(LSTM(128, return_sequences=True, input_shape=(look_back, dim) ))
model.add(LSTM(128))
#model.add(Dropout(0.2))
model.add(Dense(dim, activation='softmax'))
model.compile(loss='categorical_crossentropy', optimizer='adam')


for iteration in range(1, nb_epoch):
    model.fit(trainX, trainY, batch_size=128, verbose=0, nb_epoch=1)

    if iteration%100 == 0:
        print('-'*50)
        print('Iteration: ', iteration)
        # make predictions
        trainPredict = model.predict(trainX)
        testPredict = model.predict(testX)
        # invert predictions
        trainPredict = scaler.inverse_transform(trainPredict)
        trainY = scaler.inverse_transform(trainY)
        testPredict = scaler.inverse_transform(testPredict)
        testY = scaler.inverse_transform(testY)
        # calculate root mean squared error
        temp= trainY -  trainPredict
        trainScore = math.sqrt(mean_squared_error(trainY, trainPredict))
        print('Train Score: %.2f RMSE' % (trainScore))
        testScore = math.sqrt(mean_squared_error(testY, testPredict))
        print('Test Score: %.2f RMSE' % (testScore))


print('-'*5)
# make predictions
trainPredict = model.predict(trainX)
testPredict = model.predict(testX)
# invert predictions
trainPredict = scaler.inverse_transform(trainPredict)
trainY = scaler.inverse_transform(trainY)
testPredict = scaler.inverse_transform(testPredict)
testY = scaler.inverse_transform(testY)
# calculate root mean squared error
temp= trainY -  trainPredict
trainScore = math.sqrt(mean_squared_error(trainY, trainPredict))
print('Train Score: %.2f RMSE' % (trainScore))
testScore = math.sqrt(mean_squared_error(testY, testPredict))
print('Test Score: %.2f RMSE' % (testScore))
        
