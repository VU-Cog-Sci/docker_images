# docker_images
repo for docker scripts and images in the lab

This repo contains shell scripts using the neurodocker interface, and the latest `Dockerfile` outputs. These docker images allow us to synchronize the processing platform across the lab.


### creating Dockerfile:

(For more recent versions of this, see neurodocker.sh)

```shell
docker run --rm kaczmarj/neurodocker:master \
generate -b centos:7 -p yum \
--user=root \
--run 'mkdir /data && chmod 777 /data && chmod a+s /data' \
--install git gcc g++ inkscape ffmpeg ImageMagick  \
--afni version=latest \
--ants version=2.2.0 \
--freesurfer version=6.0.1 license_path=license \
--fsl version=5.0.10 \
--miniconda env_name=neuro yaml_file="py36.yml" \
--run="source activate neuro && git clone https://github.com/gallantlab/pycortex.git && cd pycortex && git checkout glrework-merged && python setup.py install" \
--run="echo 'export PATH=/opt/conda/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/lib/x86_64-linux-gnu' >> /etc/profile" \
--user=neuro \
--run="echo 'source activate neuro' >> /home/neuro/.bashrc" \
--workdir /home/neuro > Dockerfile
```


### To build this image:
```
docker build . -t knapenlab/nd:0.0.1test
```


### This container can be run by:
```
docker run --user neuro -i -t knapenlab/nd:0.0.1test
```