# base docker image

Base docker image containing all software used in the lab. This hosts a jupyterlab server, and can/should be used for day to day analysis and coding. 
Linking it to specific folders on the host allows for persistence etc. Multiple of these containers can be run at the same time, if the 8888 port within the container is mapped to separate alternate port numbers. 

The `neurodocker.sh` script has 
