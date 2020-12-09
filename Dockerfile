From ubuntu:16.04

MAINTAINER txhsl <teumessian@qq.com>

RUN useradd -ms /bin/bash tjark && usermod -g root tjark

USER root
WORKDIR /home/tjark

RUN sh -c '. /etc/lsb-release && echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt update && apt install -y ros-kinetic-navigation ros-kinetic-geographic-msgs ros-kinetic-serial ros-kinetic-rosauth git gcc nodejs libcurl3 openssl automake autoconf libtool cmake

RUN git clone https://github.com/mongodb/libbson.git && \
    git clone https://github.com/mongodb/mongo-c-driver.git && \
    git clone https://github.com/mongodb/mongo-cxx-driver.git && \
    git clone https://github.com/nlohmann/json.git

COPY config /tmp/
RUN mv /tmp/CMakeLists.txt mongo-cxx-driver/CMakeLists.txt

RUN cd libbson && ./autogen.sh && ./configure && make && make install && \
    cd ../mongo-c-driver && git checkout 1.17.3 && python build/calc_release_version.py > VERSION_CURRENT && mkdir cmake-build && cd cmake-build && cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF .. && cmake --build . --target install && \
    cd ../../mongo-cxx-driver && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DLIBBSON_DIR=/usr -DLIBMONGOC_DIR=/usr/local/ .. && make EP_mnmlstc_core && make && make install./configure && make && make install && \
    cd ../../json && ./autogen.sh && ./configure && make && make install

RUN pip install bson && \
    pip install pymongo

RUN wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.6.tgz && \
    tar -zxvf mongodb-linux-x86_64-3.0.6.tgz && \
    mv mongodb-linux-x86_64-3.0.6/ /usr/local/mongodb && \
    export PATH=/usr/local/mongodb4/bin:$PATH

RUN mkdir -p /var/lib/mongo && \
    mkdir -p /var/log/mongodb && \
    sudo chown tjark /var/lib/mongo && \
    sudo chown tjark /var/log/mongodb && \
    mongod --dbpath /var/lib/mongo --logpath /var/log/mongodb/mongod.log --fork && \
    nohup /usr/local/mongodb/bin/mongod --port 20000 --dbpath /home/tjark/ugv_data --auth>/dev/null 2>&1 &

CMD ["/bin/bash"]

EXPOSE 20000
EXPOSE 27017
EXPOSE 28017