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
--run="source activate neuro && git clone https://github.com/poldracklab/pydeface.git && cd pydeface && python setup.py install" \
--run="echo 'export PATH=/opt/conda/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/lib/x86_64-linux-gnu' >> /etc/profile" \
--user=neuro \
--run="echo 'source activate neuro' >> /home/neuro/.bashrc" \
--workdir /home/neuro > Dockerfile

# to build the just-created docker file
docker build . -t knapenlab/nd:0.0.2test

## to upload to docker
docker push knapenlab/nd:0.0.2test

# to convert to singularity
docker run \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /home/shared/software/knapenlab/kl-0.0.2test:/output \
--privileged -t --rm \
singularityware/docker2singularity \
knapenlab/nd:0.0.2test



#####################################################################
## run docker image, with mounted volumes on host
## 				!!!!UNTESTED!!!!!
#####################################################################

data_directory_host="/home/shared/2017/visual/nPRF_all/derivatives/pp/"
data_directory_container="/data/nPRF_all/"

code_directory_host="$HOME/projects/MB_PRF_7T/"
code_directory_container="/home/neuro/projects/MB_PRF_7T/"

portnr=8888

# as docker image
docker run -p ${portnr}:${portnr} --expose=${portnr} -v ${data_directory_host}:${data_directory_container} \
-v ${code_directory_host}:${code_directory_container} --user neuro -i -t knapenlab/nd:0.0.1test

# as singularity image
# not working yet, needs to start the jupyter lab thing and port mapping 
PYTHONPATH="" singularity run --bind /home/shared --bind /home/raw_data/ /home/shared/software/knapenlab/kl-0.0.2test 


# then start jupyter lab in docker
jupyter lab --ip 0.0.0.0 --no-browser


# and access from outside
# using a ssh pipe from your own computer to the server
portnr=8888
ssh -N -f -L localhost:${portnr}:localhost:${portnr} $USER@aeneas.labs.vu.nl


