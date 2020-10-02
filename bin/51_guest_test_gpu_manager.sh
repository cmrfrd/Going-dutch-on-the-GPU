#!/usr/bin/env sh
echo "Running tensorflow pod with strict resource requests + limits ..."
kubectl run \
        --rm \
        -it gpu-manager-test-tf \
        --restart Never \
        --requests='cpu=10m,memory=256Mi,tencent.com/vcuda-core=1,tencent.com/vcuda-memory=10' \
        --limits='cpu=100m,memory=256Mi,tencent.com/vcuda-core=1,tencent.com/vcuda-memory=10' \
        --image localhost:5000/tensorflow/tensorflow:2.2.1-gpu-py3 \
        --env="TF_FORCE_GPU_ALLOW_GROWTH=true" -- \
        python -c "
import tensorflow as tf
tf.debugging.set_log_device_placement(True)
gpus = tf.config.experimental.list_physical_devices('GPU')
print('Running computation on gpu ...')
a = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[2, 3], name='a')
b = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[3, 2], name='b')
c = tf.matmul(a, b)
print(c)
"
