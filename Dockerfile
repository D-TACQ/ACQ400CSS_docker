FROM ubuntu:latest

#install require packages
RUN apt-get update
RUN apt-get install -y xorg openjdk-8-jdk git wget curl

#Maintenance
RUN userdel -r ubuntu
RUN chmod 777 /usr/local/bin

#Create new user same as host
ARG USER_NAME USER_ID GROUP_NAME GROUP_ID
RUN groupadd --gid ${GROUP_ID} ${GROUP_NAME}
RUN useradd --uid ${USER_ID} --gid ${GROUP_ID} ${USER_NAME}
USER ${USER_NAME}

#Install cs-studio
WORKDIR /d-tacq/

RUN curl -L -O https://github.com/D-TACQ/ACQ400CSS_docker/releases/download/base/cs-studio-4.5.9-linux.gtk.x86_64.tar.gz
#RUN wget https://www.d-tacq.com/tmp/cs-studio-4.5.9-linux.gtk.x86_64.tar.gz
#COPY cs-studio-4.5.9-linux.gtk.x86_64.tar.gz .

RUN tar -xzf cs-studio-4.5.9-linux.gtk.x86_64.tar.gz
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64/jre cs-studio/
RUN echo "enabled=false" >> cs-studio/p2/org.eclipse.equinox.p2.engine/profileRegistry/DefaultProfile.profile/.data/.settings/org.eclipse.equinox.p2.ui.sdk.scheduler.prefs #disables autoupdate
RUN ln -s /d-tacq/cs-studio/cs-studio /usr/local/bin/cs-studio

#Install ACQ400CSS
RUN git clone https://github.com/D-TACQ/ACQ400CSS

#setup home dir
WORKDIR /home/${USER_NAME}
RUN ln -s /d-tacq $HOME/PROJECTS
COPY scripts scripts

ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir
RUN mkdir -p /tmp/xdg-runtime-dir && chmod 777 /tmp/xdg-runtime-dir

CMD ["/bin/bash"]

