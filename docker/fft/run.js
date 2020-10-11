import * as tf from '@tensorflow/tfjs-node-gpu'

// util
const log = console.log;

// Params
const N = 600
const T = 1.0 / 1000.0
const iterations = 500;

Array(iterations).fill().map((_, i) => {

    log(`Iter: ${i}`)
    log("  Making data ... ")
    const freq = Math.random() * (1.0 / (2 * T))
    const x = tf.range(0, N * T, T);
    const y = tf.mul(x, tf.scalar(2.0 * Math.PI * freq)).sin();

    log("  Running fft ... ")
    var fft_out = tf.spectral.rfft(y);
    fft_out = tf.mul(2.0 / N, tf.abs(fft_out.slice([0], [N / 2])))
    const freq_domain = tf.range(0.0, 1.0 / (2.0 * T), (1.0 / (2 * T)) / (N / 2))

    const index = fft_out.argMax().bufferSync().get(0);
    const captured_freq = freq_domain.bufferSync().get(index);
    log(`  Generated with freq ${freq}, captured freq ${captured_freq}`);

});
