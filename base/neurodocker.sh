version=0.0.11

#####################################################################
## create docker image, with installations
#####################################################################

docker run --rm kaczmarj/neurodocker:master \
generate docker --base debian:stretch --pkg-manager apt \
--user=root \
--run 'mkdir /data && chmod 777 /data && chmod a+s /data' \
--install git gcc g++ gfortran inkscape nano \
--afni version=latest method=binaries \
--ants version=2.2.0 method=binaries \
--freesurfer version=6.0.1 license_path=license.txt \
--fsl version=5.0.11  method=binaries \
--convert3d version=1.0.0 method=binaries \
--dcm2niix version=latest method=source \
--matlabmcr version=2012b method=binaries \
--copy py36_nov.yml /tmp/environment.yml \
--miniconda create_env=neuro yaml_file="/tmp/environment.yml" activate=true \
--copy jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py \
--add-to-entrypoint "source activate neuro" \
--neurodebian os_codename=stretch server=usa-nh --install connectome-workbench \
--workdir /data > Dockerfile

# --add-to-entrypoint "jupyter lab --ip 0.0.0.0 --no-browser --config=/etc/jupyter/jupyter_notebook_config.py" \
# --user=neuro \

# options not used
# --copy jupyter_notebook_config.py /home/neuro/.jupyter/jupyter_notebook_config.py \
# --run="source activate neuro && git clone https://github.com/gallantlab/pycortex.git && cd pycortex && git checkout equivolume && python setup.py install" \
# --run="source activate neuro && git clone https://github.com/poldracklab/pydeface.git && cd pydeface && python setup.py install" \
# --run="source activate neuro && git clone https://github.com/spinoza-centre/spynoza.git && cd spynoza && python setup.py install" \
# --run="source activate neuro && git clone https://github.com/VU-Cog-Sci/nideconv.git && cd nideconv && python setup.py install" \
# --run="echo 'export PATH=/opt/conda/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/lib/x86_64-linux-gnu' >> /etc/profile" \



#####################################################################
### to build the just-created docker file
#####################################################################

docker build . -t knapenlab/nd:${version}


#####################################################################
### to upload to docker
#####################################################################
docker push knapenlab/nd:${version}

#####################################################################
### to convert to singularity
#####################################################################

# docker run \
# -v /var/run/docker.sock:/var/run/docker.sock \
# -v /home/shared/software/knapenlab/kl-${version}:/output \
# --privileged -t --rm \
# singularityware/docker2singularity \
# knapenlab/nd:${version}

singularity build knapenlab-$VERSION.simg docker://knapenlab/nd:$VERSION

#####################################################################
## set up docker image, select which volumes to mount from host
#####################################################################

data_directory_host="/data/projects/myproject"
data_directory_container="/data/project/"

code_directory_host="$HOME/projects/mycode/"
code_directory_container="/data/code/"

external_portnr=8888
internal_portnr=8888

# this one creates files as the present user (not root).
# could replace $(id -g) with 'data', as that would probably work for /home/shared on aeneas.

# use the group id of the present user
GID=1005

#####################################################################
## run docker image, with mounted volumes on host
#####################################################################

docker run -p ${external_portnr}:${internal_portnr} --expose=${external_portnr} -v ${data_directory_host}:${data_directory_container} \
-v ${code_directory_host}:${code_directory_container} -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -u=$UID:$(id -g $USER) -i -t knapenlab/nd:${version}


#####################################################################
### as singularity image
### not working yet, needs to do port mapping which is problematic
### PYTHONPATH="" singularity run --bind /home/shared \
### --bind /home/raw_data/ /home/shared/software/knapenlab/kl-0.0.2test
#####################################################################


#####################################################################
### and access from outside - the following to be run from laptop
### for instance, using a ssh pipe from your own computer to the server
#####################################################################
external_portnr=8888
ssh -N -f -L localhost:${external_portnr}:localhost:${external_portnr} $USER@aeneas.labs.vu.nl


