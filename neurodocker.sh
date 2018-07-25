version=0.0.9nvtest

#####################################################################
## create docker image, with installations
#####################################################################

docker run --rm kaczmarj/neurodocker:master \
generate docker --base debian:stretch --pkg-manager apt \
--user=root \
--run 'mkdir /data && chmod 777 /data && chmod a+s /data' \
--install git gcc g++ gfortran inkscape \
--afni version=latest method=binaries \
--ants version=2.2.0 \
--freesurfer version=6.0.1 license_path=freesurfer_license.txt \
--fsl version=5.0.11 \
--dcm2niix version=latest method=source \
--copy py_envs/py36_nov.yml /tmp/environment.yml \
--miniconda create_env=neuro yaml_file="/tmp/environment.yml" activate=true \
--user=neuro \
--copy jupyter_notebook_config.py /home/neuro/.jupyter/jupyter_notebook_config.py \
--add-to-entrypoint "source activate neuro" \
--add-to-entrypoint "jupyter lab --ip 0.0.0.0 --no-browser --config=/home/neuro/.jupyter/jupyter_notebook_config.py" \
--workdir /home/neuro > Dockerfile


# options not used
# --copy jupyter_notebook_config.py /home/neuro/.jupyter/jupyter_notebook_config.py \
# --run="source activate neuro && git clone https://github.com/gallantlab/pycortex.git && cd pycortex && git checkout equivolume && python setup.py install" \
# --run="source activate neuro && git clone https://github.com/poldracklab/pydeface.git && cd pydeface && python setup.py install" \
# --run="source activate neuro && git clone https://github.com/spinoza-centre/spynoza.git && cd spynoza && python setup.py install" \
# --run="source activate neuro && git clone https://github.com/VU-Cog-Sci/nideconv.git && cd nideconv && python setup.py install" \
# --run="echo 'export PATH=/opt/conda/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/lib/x86_64-linux-gnu' >> /etc/profile" \



# to build the just-created docker file
docker build . -t knapenlab/nd:${version}

## to upload to docker
docker push knapenlab/nd:${version}

# to convert to singularity
docker run \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /home/shared/software/knapenlab/kl-${version}:/output \
--privileged -t --rm \
singularityware/docker2singularity \
knapenlab/nd:${version}



#####################################################################
## run docker image, with mounted volumes on host
#####################################################################
# # "nPRF_all/derivatives/pp/"

# data_directory_host="/home/shared/2017/visual/npRF_all/derivatives/pp/"
data_directory_host="/data/projects/npRF_all"
data_directory_container="/data/project/"

code_directory_host="$HOME/projects/PRF_7T/"
code_directory_container="/home/neuro/projects/code/"

external_portnr=8888
internal_portnr=8888

# as docker image
# docker run -p ${portnr}:${portnr} --expose=${portnr} -v ${data_directory_host}:${data_directory_container} \
# -v ${code_directory_host}:${code_directory_container} --user neuro -i -t knapenlab/nd:0.0.1test

# this one creates files as the present user (not root).
# could replace $(id -g) with 'data', as that would probably work for /home/shared on aeneas.

# use the group id of the present user
GID=1005
# use the group id of the 'data' group on aeneas
GID=1005

docker run -p ${external_portnr}:${internal_portnr} --expose=${external_portnr} -v ${data_directory_host}:${data_directory_container} \
-v ${code_directory_host}:${code_directory_container} -u $(id -u):$GID -i -t knapenlab/nd:${version}

# as singularity image
# not working yet, needs to start the jupyter lab thing and port mapping 
# PYTHONPATH="" singularity run --bind /home/shared --bind /home/raw_data/ /home/shared/software/knapenlab/kl-0.0.2test 


# then start jupyter lab in docker
jupyter lab --ip 0.0.0.0 --no-browser


# and access from outside
# using a ssh pipe from your own computer to the server
portnr=8888
ssh -N -f -L localhost:${portnr}:localhost:${portnr} $USER@aeneas.labs.vu.nl


