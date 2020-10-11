FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04
COPY approx_pi.cu /
RUN nvcc approx_pi.cu -o approx_pi
CMD ["./approx_pi"]
