# IMU-error-prediction-based-on-ANFIS

This project can predict the imu error by using ANFIS.  And we provide a LSTM method to compare with our method.
Our codes have been tested by a KITTI dataset. By using our code, the KITTI dataset should be downloaded.

## DEMO

  If you want to see the result visually, run the **Demo.m** to see the train and test result. The data of the demo used is the Y-direction of sequence-09300018.


## HOW TO USE (Quick start)

  The quick start is based on KITTI dataset.
  
### First step: Delete repeated data

  We use **Microsoft excel** to delete the repeated data. But if it's too much trouble for you, you can write your own code to delete.
  
### Second step: Calculate position error 

  Using **ErrorCalculation.m** to calculate and obtain the position error and other input and output values.

### Third step: Predict position error

  Run **Anfis.m** to predict the position error of IMU and to compare the results between the predicting error and truth error.

### Forth step: Compare the results

  Run **Lstm.m** to get the results based on the lstem method.
  
  
