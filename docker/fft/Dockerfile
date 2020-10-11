FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04
RUN apt-get update -y && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN \
  apt-get install -y nodejs && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
WORKDIR /work
ADD package.json /work
ADD .babelrc /work
RUN npm i
ADD run.js /work
RUN npm run build
CMD ["npm", "run", "start"]
