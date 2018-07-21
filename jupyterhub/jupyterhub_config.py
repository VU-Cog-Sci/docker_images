"""
jupyterhub_config.py-docker
---------------------------

Configuration for JupyterHub tutorial - used for docker deployment
"""

# SSL and hub port
# c.JupyterHub.ssl_key = 'jupyterhub.key'
# c.JupyterHub.ssl_cert = 'jupyterhub.crt'
# or letsencrypt:
c.JupyterHub.ssl_key = '/etc/letsencrypt/live/brainimaging.labs.vu.nl/privkey.pem'
c.JupyterHub.ssl_cert = '/etc/letsencrypt/live/brainimaging.labs.vu.nl/fullchain.pem'
c.JupyterHub.port = 443

# User whitelist - set of users allowed to use the Hub
c.Authenticator.whitelist = {'tkn219'}

# Administrators - set of users who can administer the Hub itself
c.Authenticator.admin_users = {'tkn219'}

# Authenticator
c.JupyterHub.authenticator_class = 'ldapauthenticator.LDAPAuthenticator'
c.LDAPAuthenticator.server_address = 'ldap.vu.nl'
c.LDAPAuthenticator.bind_dn_template = []

# Spawner
from dockerspawner import DockerSpawner
c.JupyterHub.spawner_class = DockerSpawner

# Hub IP and port
#
# By default, the Hub's API listens on localhost.
# Yet, a docker container can't see the Hub's localhost.
# Set the Hub's IP address to the docker0 address and
# tell the Hub to listen on its docker network.
# netifaces is a convenience library to gather IP information.
import netifaces
import platform
if platform.system() == 'Darwin':
    en0 = netifaces.ifaddresses('en0')
    docker_ipv4 = en0[netifaces.AF_INET][0]
else:
    docker0 = netifaces.ifaddresses('docker0')
    docker_ipv4 = docker0[netifaces.AF_INET][0]
c.JupyterHub.hub_ip = docker_ipv4['addr']