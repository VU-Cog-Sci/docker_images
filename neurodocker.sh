#####################################################################
## create docker image, with installations
#####################################################################

docker run --rm kaczmarj/neurodocker:master \
generate -b centos:7 -p yum \
--user=root \
--run 'mkdir /data && chmod 777 /data && chmod a+s /data' \
--install git gcc g++ inkscape  \
--afni version=latest \
--ants version=2.2.0 \
--freesurfer version=6.0.1 license_path=freesurfer_license.txt \
--fsl version=5.0.10 \
--miniconda env_name=neuro yaml_file="py_envs/py36.yml" \
--run="source activate neuro && git clone https://github.com/gallantlab/pycortex.git && cd pycortex && git checkout glrework-merged && python setup.py install" \
--run="echo 'export PATH=/opt/conda/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/lib/x86_64-linux-gnu' >> /etc/profile" \
--user=neuro \
--run="echo 'source activate neuro' >> /home/neuro/.bashrc" \
--workdir /home/neuro > Dockerfile

docker build . -t knapenlab/nd:0.0.1test

#####################################################################
## run docker image, with mounted volumes on host
## 				!!!!UNTESTED!!!!!
#####################################################################

data_directory_host="/home/shared/2017/visual/nPRF_all/derivatives/pp/"
data_directory_container="/data/nPRF_all/"

code_directory_host="$HOME/projects/MB_PRF_7T/"
code_directory_container="/home/neuro/projects/MB_PRF_7T/"

# docker run -v ${data_directory_host}:${data_directory_container} \
# -v ${code_directory_host}:${code_directory_container} -i -t knapenlab/nd:0.0.1test

docker run --user neuro -i -t knapenlab/nd:0.0.1test

## to upload
docker push knapenlab/nd:0.0.1test
