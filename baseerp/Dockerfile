FROM sdwot-workspace 

ENV HOME=/home/sdwot
##########creating a new conda env ####################3
RUN  conda create -n myenv python=3.7  -y && conda install -n myenv virtualenv -y

################ postgresql setup ############
USER root
RUN  sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&\
      wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
      apt-get update &&  apt-get -y install postgresql-12 


################ sdwot erp dependencies ##################

RUN  add-apt-repository ppa:deadsnakes/ppa && apt-get update -y &&apt-get autoremove -y &&  apt-get install git python3-pip build-essential wget python3.7-dev python3.7-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less &&\
      wget --no-verbose https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb &&\
       apt-get install ./wkhtmltox_0.12.5-1.bionic_amd64.deb && rm -rf wkhtmltox_0.12.5-1.bionic_amd64.deb

###### update code-server to 4.0.1

RUN VS_CODE_VERSION=4.0.1 &&\
    # Use yarn install since it is smaller
   # yarn --production --frozen-lockfile global add code-server@"$VS_CODE_VERSION"
   # yarn  add code-server@"$VS_CODE_VERSION"
   yarn global remove code-server &&\
   wget -q https://github.com/coder/code-server/releases/download/v4.0.1/code-server_4.0.1_amd64.deb  -O ./code-server.deb &&\
   apt-get update && apt-get install -y ./code-server.deb && rm ./code-server.deb && ln -s /usr/bin/code-server /usr/local/bin/code-server

############### vs code extensions #####################
USER sdwot

RUN  mkdir -p /home/sdwot/.vscode/extensions && cd /home/sdwot/.vscode/extensions && SLEEP_TIMER=10 &&\
     wget --no-verbose https://github.com/microsoft/vscode-python/releases/download/2021.12.1559732655/ms-python-release.vsix &&\
     bsdtar -xf ms-python-release.vsix extension && mv extension ms-python.python-2021.12.1559732655 && sleep $SLEEP_TIMER && rm -rf extension && rm -rf ms-python-release.vsix &&\
     code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  ms-toolsai.jupyter &&\ 
     code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  formulahendry.auto-close-tag &&\
     code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  formulahendry.code-runner &&\
     code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  eamodio.gitlens &&\
     code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  k--kato.intellij-idea-keybindings &&\
     code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  xyz.local-history &&\
    code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  cweijan.vscode-postgresql-client2 &&\
     code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  mechatroner.rainbow-csv &&\
     code-server --extensions-dir /home/sdwot/.vscode/extensions  --install-extension  redhat.vscode-xml
     


COPY --chown=sdwot:sdwot keybindings.json /home/sdwot/.config/Code/User/
COPY --chown=sdwot:sdwot usersettings.json  /home/sdwot/.config/Code/User/settings.json
RUN  mkdir /home/sdwot/Desktop/.vscode

COPY --chown=sdwot:sdwot settings.json launch.json /home/sdwot/Desktop/.vscode/

COPY dbstart dbstop dbrestart  /usr/bin/
 
COPY postgres.conf /etc/supervisor/conf.d/

############## postgres setup ##############
WORKDIR /var/lib/postgresql

ARG DATE=unknown

USER postgres

RUN  /usr/lib/postgresql/12/bin/./initdb -D /var/lib/postgresql/12/data  &&     sed -i /^host/s/trust/md5/g 12/data/pg_hba.conf &&\
     /usr/bin/echo "host    all             all             192.168.180.0/24        md5"  >> /var/lib/postgresql/12/data/pg_hba.conf&&\
     /usr/bin/echo "host    all             all             192.168.181.0/24        md5"  >> /var/lib/postgresql/12/data/pg_hba.conf&&\
     /usr/bin/echo "host    all             all             172.33.0.0/16        md5"  >> /var/lib/postgresql/12/data/pg_hba.conf&&\
     /usr/bin/echo "listen_addresses = '*'" >> /var/lib/postgresql/12/data/postgresql.conf &&\
     /usr/lib/postgresql/12/bin/./pg_ctl -D /var/lib/postgresql/12/data -l /var/lib/postgresql/logfile start -t 240 &&\
     /usr/bin/psql -c "create user sdwot with password 'sdwot' createdb;" 

USER sdwot

RUN mkdir /home/sdwot/docker/ /home/sdwot/.ssh && echo "Host phabricator.sdwot.ai\n HostName phabricator.sdwot.ai\n  user git\n  IdentityFile /home/sdwot/docker/id_rsa\n  IdentitiesOnly yes" >> /home/sdwot/.ssh/config 

COPY --chown=sdwot:sdwot id_rsa id_rsa.pub /home/sdwot/docker/

WORKDIR /home/sdwot

#ARG DATE=unknown

############# sdwot erp setup #############
RUN  ssh-keyscan -H  phabricator.sdwot.ai  >>  /home/sdwot/.ssh/known_hosts &&\
     /opt/conda/envs/myenv/bin/python -m venv erp && cd Desktop &&  git clone ssh://git@phabricator.sdwot.ai:2223/source/sdwot.git &&\
     mkdir /home/sdwot/.cache/&& export PIP_CACHE_DIR=/home/sdwot/.cache/ &&\
     cd sdwot && git flow init -fd && git flow feature pull origin Saideepa  &&\
    /home/sdwot/erp/bin/python -m pip install -r /home/sdwot/Desktop/sdwot/requirements.txt &&\
    /home/sdwot/erp/bin/python -m pip install  autopep8


RUN  echo "[options]\nassert_exit_level = warn\ncsv_internal_sep = ,\ndb_host = localhost\ndb_name = False\ndb_password = sdwot\ndb_port = 5432\ndata_dir = /home/sdwot/erp/data\ndb_user = sdwot\ndemo = {}\nemail_from = False\nhttp_enable = True\n#limit_memory_hard = 4831838208\n#limit_memory_soft = 4294967296\nlimit_request = 8192\nlimit_time_cpu = 6000000000\nlimit_time_real = 12000000000\nlimit_time_real_cron = -1\nlist_db = True\nlog_db = False\nlog_db_level = warning\nlog_handler = :INFO\nlog_level = info\nlogrotate = True\nlongpolling_port = 8052\nmax_cron_threads = 1\nosv_memory_age_limit = 1.0\nosv_memory_count_limit = False\n#pg_path = None\npidfile = /home/sdwot/erp/log/erp-server.pid\nproxy_mode = True\nreportgz = False\nscreencasts = None\nserver_wide_modules = base,web\nsmtp_password = False\nsmtp_server = localhost\nsmtp_ssl = False\nsmtp_user = False\nsyslog = False\ntest_enable = False\ntest_file = False\ntest_tags = None\ntranslate_modules = ['all']\nunaccent = False\nupgrades_paths = \nwithout_demo = False" > /home/sdwot/erp/.erp_serverrc  && mkdir /home/sdwot/erp/log

RUN sed -i 's|/home/sdwot/docker|/workspace/.ssh|g' /home/sdwot/.ssh/config && echo "export PIP_CACHE_DIR=/home/sdwot/.cache/" > /home/sdwot/.bashrc && touch /workspace/.gitconfig && ln -s /workspace/.gitconfig /home/sdwot/.gitconfig 

USER root

ENV HOME=/root/

ENV WORKSPACE_HOME="/home/sdwot/Desktop" 

RUN npm install -g live-server  && chmod +x /usr/bin/dbstart /usr/bin/dbstop /usr/bin/dbrestart && echo "postgres\npostgres"|passwd postgres && echo "export PATH=$PATH:/resources/.pyenv/bin:/home/sdwot/.local/bin:/home/sdwot/.local/pipx/venvs/supervisor/bin" >> /root/.zshrc && rm -rf /usr/bin/scp

RUN chown -R postgres:postgres /var/lib/postgresql /var/run/postgresql

####EXPOSE 8069
