#!/usr/bin/env sh
kubectl run \
        --rm \
        -it figlet \
        --restart Never \
        --request='cpu=10m,memory=256Mi' \
        --limits='cpu=100m,memory=256Mi' \
        --image localhost:5000/tensorflow/tensorflow:2.2.1-gpu-py3 -- \
python -c <<EOF
import tensorflow as tf
tf.debugging.set_log_device_placement(True)
print(tf.config.experimental.list_physical_devices('GPU'))

a = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[2, 3], name='a')
b = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[3, 2], name='b')
c = tf.matmul(a, b)
print(c)
EOF
