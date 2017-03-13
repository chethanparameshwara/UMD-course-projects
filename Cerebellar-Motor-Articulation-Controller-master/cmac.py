from numpy import concatenate, array

from neupy.utils import format_data
from neupy.core.properties import IntProperty
from neupy.network.learning import SupervisedLearningMixin
from neupy.network.base import BaseNetwork


__all__ = ('CMAC',)


class CMAC(SupervisedLearningMixin, BaseNetwork):

    quantization = IntProperty(default=10, minval=1)
    associative_unit_size = IntProperty(default=2, minval=2)

    def __init__(self, **options):
        self.weight_con = {}
        self.weight_dis = {}
        super(CMAC, self).__init__(**options)

    def predict_con(self, input_data, output_data):
        input_data = format_data(input_data)

        get_memory_coords = self.get_memory_coords
        get_result_by_coords_con = self.get_result_by_coords_con
        predicted = []
        pred_error = []
        i = 0

        for input_sample, test_sample in zip(self.quantize(input_data), output_data):
            coords = get_memory_coords(input_sample)
            predicted.append(get_result_by_coords_con(coords))
            pred_error.append(abs(test_sample -predicted[i]))
            i = i+1

        return array(predicted), array(pred_error)

    def get_result_by_coords_con(self, coords):
        return sum(
            self.weight_con.setdefault(coord, 0) for coord in coords
        ) / self.associative_unit_size

    def get_memory_coords(self, quantized_value):
        assoc_unit_size = self.associative_unit_size

        for i in range(assoc_unit_size):
            point = ((quantized_value + i) / assoc_unit_size).astype(int)
            yield tuple(concatenate([point, [i]]))

    def quantize(self, input_data):
        return (input_data * self.quantization).astype(int)

    def train_epoch_con(self, input_train, target_train):
        get_memory_coords = self.get_memory_coords
        get_result_by_coords_con = self.get_result_by_coords_con
        weight_con = self.weight_con
        global_step = self.step
        quantized_input = self.quantize(input_train)
        errors = 0

        for input_sample, target_sample in zip(quantized_input, target_train):
            coords = list(get_memory_coords(input_sample))
            predicted = get_result_by_coords_con(coords)
            #For COntinuous
            step = ((input_sample - (input_sample/10)*10).astype(float)/input_sample)
            # print input_sample
            # print ((input_sample/10)*10)
            # print step
            error = target_sample - predicted
            # print error
            #print "printingerror"
            #print error
            for coord in coords:
                # print"printing coords"
                # print coord[0], coord[1]
                if coord[1] == 0: 
                    weight_con[coord] += global_step* 0.01 - step * error
                elif coord[1] ==self.associative_unit_size -1:
                    weight_con[coord] += global_step* step * error
                else:
                    weight_con[coord] += global_step*error

            errors += abs(error)
            # print "printing errors"
            # print error
        return errors / input_train.shape[0]

    def predict_dis(self, input_data, output_data):
        input_data = format_data(input_data)

        get_memory_coords = self.get_memory_coords
        get_result_by_coords_dis = self.get_result_by_coords_dis
        predicted = []
        pred_error = []
        i = 0

        for input_sample, test_sample in zip(self.quantize(input_data), output_data):
            coords = get_memory_coords(input_sample)
            predicted.append(get_result_by_coords_dis(coords))
            # print test_sample
            # print predicted[i]
            pred_error.append(abs(test_sample -predicted[i]))
            i = i+1

        return array(predicted), array(pred_error)

    def get_result_by_coords_dis(self, coords):
        return sum(
            self.weight_dis.setdefault(coord, 0) for coord in coords
        ) / self.associative_unit_size

    def train_epoch_dis(self, input_train, target_train):
        get_memory_coords = self.get_memory_coords
        get_result_by_coords_dis = self.get_result_by_coords_dis
        weight_dis = self.weight_dis
        global_step = self.step
        quantized_input = self.quantize(input_train)
        errors = 0

        for input_sample, target_sample in zip(quantized_input, target_train):
            coords = list(get_memory_coords(input_sample))
            predicted = get_result_by_coords_dis(coords)
            #For COntinuous
            step = ((input_sample - (input_sample/10)*10).astype(float)/input_sample)
            # print input_sample
            # print ((input_sample/10)*10)
            # print step
            error = target_sample - predicted
            for coord in coords:
                weight_dis[coord] += global_step*error
                    

            errors += abs(error)
        return errors / input_train.shape[0]
