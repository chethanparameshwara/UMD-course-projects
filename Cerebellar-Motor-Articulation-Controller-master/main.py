"""
Robot Learning Assignment 1
CMAC Implementation
Author - Chethan Mysore Parameshwara
"""
import numpy as np
import matplotlib.pyplot as plt

from neupy import environment
import cmac as cmac

environment.reproducible()
plt.style.use('ggplot')

input_train = np.reshape(np.linspace(0.1, 4 * np.pi, 200), (200, 1))
input_test = np.reshape(np.sort(4 * np.pi * np.random.random(100)), (100, 1))

target_train = np.sin(input_train)
target_test = np.sin(input_test)
predicted_error_con = np.zeros( (22,1))
predicted_error_dis = np.zeros( (22,1))


"""
Discrete CMAC
"""
cmacs_dis = [cmac.CMAC(
		quantization=100,
		associative_unit_size=i,
		step=1,
		verbose=True,
		show_epoch='4 times'
	) for i in range(3, 25)]

for dis in range(1, 22):

	# Training
	for epoch in range(1, 100): 
		error = cmacs_dis[dis].train_epoch_dis(input_train, target_train)
	# Testing
	predicted_test, pred_error = cmacs_dis[dis].predict_dis(input_test, target_test)
	predicted_error_dis[dis] = abs(sum(pred_error)/input_train.shape[0])
	plt.figure(1)

	if dis == 3 or dis == 6 or dis==9 or dis ==12 or dis == 15 or dis==18 :

		plt.subplot(320+dis/3)
		plt.xlabel('Output')
		plt.ylabel('Input')
		plt.title(' Discrete - model output vs expected output - window size %d' %dis)
		plt.plot(input_train, target_train, label='Training')
		plt.plot(input_test, predicted_test,label='Testing')

			



"""
Continuous CMAC
"""
cmacs_con = [cmac.CMAC(
		quantization=100,
		associative_unit_size=i,
		step=1,
		verbose=True,
		show_epoch='4 times'
	) for i in range(3, 25)]

for con in range(1, 22):

	# Training
	for epoch in np.arange( 10, 100, 10 ): 
		error = cmacs_con[con].train_epoch_con(input_train, target_train)
	# Testing
	predicted_test, pred_error = cmacs_con[con].predict_con(input_test, target_test)
	predicted_error_con[con] = sum(pred_error)/input_train.shape[0]
	plt.figure(2)
	if con == 3 or con == 6 or con==9 or con ==12 or con == 15 or con==18 :

		plt.subplot(320+con/3)
		plt.xlabel('Output')
		plt.ylabel('Input')
		plt.title(' Continuous - model output vs expected output - window size %d' %con)
		plt.plot(input_train, target_train, label='Training')
		plt.plot(input_test, predicted_test,label='Testing')




plt.figure(3)
plt.xlabel(' Generalization Window Size')
plt.ylabel('Test Error')
plt.title(' Test Error vs Generalization Window')
plt.plot( np.arange( 4, 25, 1 ),predicted_error_con[1:,:],color='blue', label="Continuous")
plt.plot( np.arange( 4, 25, 1 ),predicted_error_dis[1:,:],color='red', label="Discrete")
plt.show()


