FROM ubuntu:20.04

USER root

### BASICS ###
# Technical Environment Variables
ENV \
    SHELL="/bin/bash" \
    HOME="/root"  \
    # Nobteook server user: https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile#L33
    NB_USER="root" \
    USER_GID=0 \
    XDG_CACHE_HOME="/root/.cache/" \
    XDG_RUNTIME_DIR="/tmp" \
    DISPLAY=":1" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    RESOURCES_PATH="/resources" \
    SSL_RESOURCES_PATH="/resources/ssl" \
    WORKSPACE_HOME="/workspace"

WORKDIR $HOME

# Make folders
RUN \
    mkdir $RESOURCES_PATH && chmod a+rwx $RESOURCES_PATH && \
    mkdir $WORKSPACE_HOME && chmod a+rwx $WORKSPACE_HOME && \
    mkdir $SSL_RESOURCES_PATH && chmod a+rwx $SSL_RESOURCES_PATH

# Layer cleanup script
COPY resources/scripts/clean-layer.sh  /usr/bin/clean-layer.sh
COPY resources/scripts/fix-permissions.sh  /usr/bin/fix-permissions.sh

 # Make clean-layer and fix-permissions executable
 RUN \
    chmod a+rwx /usr/bin/clean-layer.sh && \
    chmod a+rwx /usr/bin/fix-permissions.sh

# Generate and Set locals
# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container#38553499
RUN \
    apt-get update && \
    apt-get install -y apt-utils locales && \
    # install locales-all?
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    # Cleanup
    clean-layer.sh

ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en"

# Install basics
RUN \
    # TODO add repos?
    # add-apt-repository ppa:apt-fast/stable
    # add-apt-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main'
    apt-get update --fix-missing && \
    apt-get install -y sudo apt-utils && \
    apt-get upgrade -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # This is necessary for apt to access HTTPS sources:
        apt-transport-https \
        gnupg-agent \
        gpg-agent \
        gnupg2 \
        ca-certificates \
        build-essential \
        pkg-config \
        software-properties-common \
        lsof \
        net-tools \
        libcurl4 \
        curl \
        wget \
        cron \
        openssl \
        iproute2 \
        psmisc \
        tmux \
        dpkg-sig \
        uuid-dev \
        csh \
        xclip \
        clinfo \
        time \
        libssl-dev \
        libgdbm-dev \
        libncurses5-dev \
        libncursesw5-dev \
        # required by pyenv
        libreadline-dev \
        libedit-dev \
        xz-utils \
        gawk \
        # Simplified Wrapper and Interface Generator (5.8MB) - required by lots of py-libs
        swig \
        # Terminal multiplexer
        screen \
        # Editor
        nano \
	vim \
        # Find files
        locate \
        # XML Utils
        xmlstarlet \
        # GNU parallel
        parallel \
        # style sheet preprocessor
        less \
        # Print dir tree
        tree \
        # Bash autocompletion functionality
        bash-completion \
        # ping support
        iputils-ping \
        # Map remote ports to localhosM
        socat \
        # Json Processor
        jq \
        rsync \
        # VCS:
        git \
        subversion \
        jed \
        # odbc drivers
        unixodbc unixodbc-dev \
        # Compression Libs
        # also install rar/unrar? but both are propriatory or unar (40MB)
        zip \
        gzip \
        unzip \
        bzip2 \
        lzop \
	    # deprecates bsdtar (https://ubuntu.pkgs.org/20.04/ubuntu-universe-i386/libarchive-tools_3.4.0-2ubuntu1_i386.deb.html)
        libarchive-tools \
        zlibc \
        # unpack (almost) everything with one command
        unp \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev && \
    # Update git to newest version
    add-apt-repository -y ppa:git-core/ppa  && \
    apt-get update && \
    apt-get install -y --no-install-recommends git && \
    # Fix all execution permissions
    chmod -R a+rwx /usr/local/bin/ && \
    # configure dynamic linker run-time bindings
    ldconfig && \
    # Fix permissions
    fix-permissions.sh $HOME && \
    # Cleanup
    clean-layer.sh

# Add tini
RUN wget --no-verbose https://github.com/krallin/tini/releases/download/v0.19.0/tini -O /tini && \
    chmod +x /tini

# prepare ssh for inter-container communication for remote python kernel
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-client \
        openssh-server \
        # SSLH for SSH + HTTP(s) Multiplexing
        sslh \
        # SSH Tooling
        autossh \
        mussh && \
    chmod go-w $HOME && \
    mkdir -p $HOME/.ssh/ && \
    # create empty config file if not exists
    touch $HOME/.ssh/config  && \
    sudo chown -R $NB_USER:users $HOME/.ssh && \
    chmod 700 $HOME/.ssh && \
    printenv >> $HOME/.ssh/environment && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Fix permissions
    fix-permissions.sh $HOME && \
    # Cleanup
    clean-layer.sh

RUN \
    OPEN_RESTY_VERSION="1.19.3.2" && \
    mkdir $RESOURCES_PATH"/openresty" && \
    cd $RESOURCES_PATH"/openresty" && \
    apt-get update && \
    apt-get purge -y nginx nginx-common && \
    # libpcre required, otherwise you get a 'the HTTP rewrite module requires the PCRE library' error
    # Install apache2-utils to generate user:password file for nginx.
    apt-get install -y libssl-dev libpcre3 libpcre3-dev apache2-utils && \
    wget --no-verbose https://openresty.org/download/openresty-$OPEN_RESTY_VERSION.tar.gz  -O ./openresty.tar.gz && \
    tar xfz ./openresty.tar.gz && \
    rm ./openresty.tar.gz && \
    cd ./openresty-$OPEN_RESTY_VERSION/ && \
    # Surpress output - if there is a problem remove  > /dev/null
    ./configure --with-http_stub_status_module --with-http_sub_module > /dev/null && \
    make -j2 > /dev/null && \
    make install > /dev/null && \
    # create log dir and file - otherwise openresty will throw an error
    mkdir -p /var/log/nginx/ && \
    touch /var/log/nginx/upstream.log && \
    cd $RESOURCES_PATH && \
    rm -r $RESOURCES_PATH"/openresty" && \
    # Fix permissions
    chmod -R a+rwx $RESOURCES_PATH && \
    # Cleanup
    clean-layer.sh

ENV PATH=/usr/local/openresty/nginx/sbin:$PATH

COPY resources/nginx/lua-extensions /etc/nginx/nginx_plugins

### END BASICS ###

### RUNTIMES ###
# Install Miniconda: https://repo.continuum.io/miniconda/

ENV \
    # TODO: CONDA_DIR is deprecated and should be removed in the future
    CONDA_DIR=/opt/conda \
    CONDA_ROOT=/opt/conda \
    PYTHON_VERSION="3.8.10" \
    CONDA_PYTHON_DIR=/opt/conda/lib/python3.8 \
    MINICONDA_VERSION=4.9.2 \
    MINICONDA_MD5=122c8c9beb51e124ab32a0fa6426c656 \
    CONDA_VERSION=4.9.2

RUN wget --no-verbose https://repo.anaconda.com/miniconda/Miniconda3-py38_${CONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
    echo "${MINICONDA_MD5} *miniconda.sh" | md5sum -c - && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_ROOT && \
    export PATH=$CONDA_ROOT/bin:$PATH && \
    rm ~/miniconda.sh && \
    # Configure conda
    # TODO: Add conde-forge as main channel -> remove if testted
    # TODO, use condarc file
    $CONDA_ROOT/bin/conda config --system --add channels conda-forge && \
    $CONDA_ROOT/bin/conda config --system --set auto_update_conda False && \
    $CONDA_ROOT/bin/conda config --system --set show_channel_urls True && \
    $CONDA_ROOT/bin/conda config --system --set channel_priority strict && \
    # Deactivate pip interoperability (currently default), otherwise conda tries to uninstall pip packages
    $CONDA_ROOT/bin/conda config --system --set pip_interop_enabled false && \
    # Update conda
    $CONDA_ROOT/bin/conda update -y -n base -c defaults conda && \
    $CONDA_ROOT/bin/conda update -y setuptools && \
    $CONDA_ROOT/bin/conda install -y conda-build && \
    # Update selected packages - install python 3.8.x
    $CONDA_ROOT/bin/conda install -y --update-all python=$PYTHON_VERSION && \
    # Link Conda
    ln -s $CONDA_ROOT/bin/python /usr/local/bin/python && \
    ln -s $CONDA_ROOT/bin/conda /usr/bin/conda && \
    # Update
    $CONDA_ROOT/bin/conda install -y pip && \
    $CONDA_ROOT/bin/pip install --upgrade pip && \
    chmod -R a+rwx /usr/local/bin/ && \
    # Cleanup - Remove all here since conda is not in path as of now
    # find /opt/conda/ -follow -type f -name '*.a' -delete && \
    # find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    $CONDA_ROOT/bin/conda clean -y --packages && \
    $CONDA_ROOT/bin/conda clean -y -a -f  && \
    $CONDA_ROOT/bin/conda build purge-all && \
    # Fix permissions
    fix-permissions.sh $CONDA_ROOT && \
    clean-layer.sh

ENV PATH=$CONDA_ROOT/bin:$PATH

# There is nothing added yet to LD_LIBRARY_PATH, so we can overwrite
ENV LD_LIBRARY_PATH=$CONDA_ROOT/lib

# Install pyenv to allow dynamic creation of python versions
RUN git clone https://github.com/pyenv/pyenv.git $RESOURCES_PATH/.pyenv && \
    # Install pyenv plugins based on pyenv installer
    git clone https://github.com/pyenv/pyenv-virtualenv.git $RESOURCES_PATH/.pyenv/plugins/pyenv-virtualenv  && \
    git clone git://github.com/pyenv/pyenv-doctor.git $RESOURCES_PATH/.pyenv/plugins/pyenv-doctor && \
    git clone https://github.com/pyenv/pyenv-update.git $RESOURCES_PATH/.pyenv/plugins/pyenv-update && \
    git clone https://github.com/pyenv/pyenv-which-ext.git $RESOURCES_PATH/.pyenv/plugins/pyenv-which-ext && \
    apt-get update && \
    # TODO: lib might contain high vulnerability
    # Required by pyenv
    apt-get install -y --no-install-recommends libffi-dev && \
    clean-layer.sh

# Add pyenv to path
ENV PATH=$RESOURCES_PATH/.pyenv/shims:$RESOURCES_PATH/.pyenv/bin:$PATH \
    PYENV_ROOT=$RESOURCES_PATH/.pyenv

# Install pipx
RUN pip install pipx && \
    # Configure pipx
    python -m pipx ensurepath && \
    # Cleanup
    clean-layer.sh
ENV PATH=$HOME/.local/bin:$PATH

# Install node.js
RUN \
    apt-get update && \
    # https://nodejs.org/en/about/releases/ use even numbered releases, i.e. LTS versions
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && \
    apt-get install -y nodejs && \
    # As conda is first in path, the commands 'node' and 'npm' reference to the version of conda.
    # Replace those versions with the newly installed versions of node
    rm -f /opt/conda/bin/node && ln -s /usr/bin/node /opt/conda/bin/node && \
    rm -f /opt/conda/bin/npm && ln -s /usr/bin/npm /opt/conda/bin/npm && \
    # Fix permissions
    chmod a+rwx /usr/bin/node && \
    chmod a+rwx /usr/bin/npm && \
    # Fix node versions - put into own dir and before conda:
    mkdir -p /opt/node/bin && \
    ln -s /usr/bin/node /opt/node/bin/node && \
    ln -s /usr/bin/npm /opt/node/bin/npm && \
    # Update npm
    /usr/bin/npm install -g npm && \
    # Install Yarn
    /usr/bin/npm install -g yarn && \
    # Install typescript
    /usr/bin/npm install -g typescript && \
    # Install webpack - 32 MB
    /usr/bin/npm install -g webpack && \
    # Install node-gyp
    /usr/bin/npm install -g node-gyp && \
    # Update all packages to latest version
    /usr/bin/npm update -g && \
    # Cleanup
    clean-layer.sh

ENV PATH=/opt/node/bin:$PATH

# Java - removed

### END RUNTIMES ###

### PROCESS TOOLS ###

# Removed XRDP

# Install supervisor for process supervision
RUN \
    apt-get update && \
    # Create sshd run directory - required for starting process via supervisor
    mkdir -p /var/run/sshd && chmod 400 /var/run/sshd && \
    # Install rsyslog for syslog logging
    apt-get install -y --no-install-recommends rsyslog && \
    pipx install supervisor && \
    pipx inject supervisor supervisor-stdout && \
    # supervisor needs this logging path
    mkdir -p /var/log/supervisor/ && \
    # Cleanup
    clean-layer.sh

### END PROCESS TOOLS ###

### GUI TOOLS ###


# Install Web Tools - Offered via Jupyter Tooling Plugin

## VS Code Server: https://github.com/codercom/code-server
COPY resources/tools/vs-code-server.sh $RESOURCES_PATH/tools/vs-code-server.sh
RUN \
    /bin/bash $RESOURCES_PATH/tools/vs-code-server.sh --install && \
    # Cleanup
    clean-layer.sh


## Glances webtool is installed in python section below via requirements.txt


ARG ARG_WORKSPACE_FLAVOR="minimal"
ENV WORKSPACE_FLAVOR=$ARG_WORKSPACE_FLAVOR



### END GUI TOOLS ###

### DATA SCIENCE BASICS ###

## Python 3
# Data science libraries requirements
COPY resources/libraries ${RESOURCES_PATH}/libraries

### Install main data science libs
RUN \
    ln -s -f $CONDA_ROOT/bin/python /usr/bin/python && \
    apt-get update && \
    # upgrade pip
    pip install --upgrade pip && \
    # If minimal flavor - install
        conda install -y --update-all 'python='$PYTHON_VERSION nomkl ; \
    # Install some basics - required to run container
    conda install -y --update-all \
            'python='$PYTHON_VERSION \
            'ipython=7.24.*' \
            'notebook=6.4.*' \
            'jupyterlab=3.0.*' \
            # TODO: nbconvert 6.x makes problems with template_path
            'nbconvert=5.6.*' \
            # TODO: temp fix: yarl version 1.5 is required for lots of libraries.
            'yarl==1.5.*' \
            # TODO install scipy, numpy, sklearn, and numexpr via conda for mkl optimizaed versions: https://docs.anaconda.com/mkl-optimizations/
            'scipy==1.7.*' \
            'numpy==1.19.*' \
            scikit-learn \
            numexpr && \
            # installed via apt-get and pip: protobuf \
            # installed via apt-get: zlib  && \
    # Switch of channel priority, makes some trouble
    conda config --system --set channel_priority false && \
    # Install minimal pip requirements
    pip install --no-cache-dir --upgrade --upgrade-strategy only-if-needed -r ${RESOURCES_PATH}/libraries/requirements-minimal.txt && \
    # Fix permissions
    fix-permissions.sh $CONDA_ROOT && \
    # Cleanup
    clean-layer.sh

# Fix conda version
RUN \
    # Conda installs wrong node version - relink conda node to the actual node
    rm -f /opt/conda/bin/node && ln -s /usr/bin/node /opt/conda/bin/node && \
    rm -f /opt/conda/bin/npm && ln -s /usr/bin/npm /opt/conda/bin/npm

### END DATA SCIENCE BASICS ###

### JUPYTER ###

COPY \
    resources/jupyter/start.sh \
    resources/jupyter/start-notebook.sh \
    resources/jupyter/start-singleuser.sh \
    /usr/local/bin/

# Configure Jupyter / JupyterLab
# Add as jupyter system configuration
COPY resources/jupyter/nbconfig /etc/jupyter/nbconfig
COPY resources/jupyter/jupyter_notebook_config.json /etc/jupyter/



# Install Jupyter Tooling Extension
COPY resources/jupyter/extensions $RESOURCES_PATH/jupyter-extensions
RUN \
    # Create empty notebook configuration
    mkdir -p $HOME/.jupyter/nbconfig/
RUN \
    pip install --no-cache-dir $RESOURCES_PATH/jupyter-extensions/tooling-extension/ && \
    # Cleanup
    clean-layer.sh

# Install and activate ZSH
COPY resources/tools/oh-my-zsh.sh $RESOURCES_PATH/tools/oh-my-zsh.sh

RUN \
    # Install ZSH
    /bin/bash $RESOURCES_PATH/tools/oh-my-zsh.sh --install && \
    # Make zsh the default shell
    # Initialize conda for command line activation
    # TODO do not activate for now, opening the bash shell is a bit slow
    # conda init bash && \
    conda init zsh && \
    chsh -s $(which zsh) $NB_USER && \
    # Install sdkman - needs to be executed after zsh
    curl -s https://get.sdkman.io | bash && \
    # Cleanup
    clean-layer.sh

# Install Git LFS
COPY resources/tools/git-lfs.sh $RESOURCES_PATH/tools/git-lfs.sh

RUN \
    /bin/bash $RESOURCES_PATH/tools/git-lfs.sh --install && \
    # Cleanup
    clean-layer.sh

### VSCODE ###

# Install vscode extension
# https://github.com/cdr/code-server/issues/171
# Alternative install: /usr/local/bin/code-server --user-data-dir=$HOME/.config/Code/ --extensions-dir=$HOME/.vscode/extensions/ --install-extension ms-python-release && \
### END VSCODE ###


### CONFIGURATION ###

# Copy files into workspace
COPY \
    resources/docker-entrypoint.py \
    resources/5xx.html \
    $RESOURCES_PATH/

# Copy scripts into workspace
COPY resources/scripts $RESOURCES_PATH/scripts

# Create Desktop Icons for Tooling
COPY resources/branding $RESOURCES_PATH/branding

# Configure Home folder (e.g. xfce)
COPY resources/home/ $HOME/
RUN mkdir -p /home/sdwot/.config
COPY   resources/home/.config/xfce4/ /home/sdwot/.config/
# Copy some configuration files
COPY resources/ssh/ssh_config resources/ssh/sshd_config  /etc/ssh/
COPY resources/nginx/nginx.conf /etc/nginx/nginx.conf
COPY resources/config/xrdp.ini /etc/xrdp/xrdp.ini

# Configure supervisor process
COPY resources/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
# Copy all supervisor program definitions into workspace
COPY resources/supervisor/programs/ /etc/supervisor/conf.d/

# Assume yes to all apt commands, to avoid user confusion around stdin.
COPY resources/config/90assumeyes /etc/apt/apt.conf.d/


# Add tensorboard patch - use tensorboard jupyter plugin instead of the actual tensorboard magic

# Additional jupyter configuration
COPY resources/jupyter/jupyter_notebook_config.py /etc/jupyter/
#COPY resources/jupyter/ipython_config.py /etc/ipython/ipython_config.py

# Branding of various components
RUN \
    # Jupyter Branding
    cp -f $RESOURCES_PATH/branding/logo.png $CONDA_PYTHON_DIR"/site-packages/notebook/static/base/images/logo.png" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $CONDA_PYTHON_DIR"/site-packages/notebook/static/base/images/favicon.ico" && \
    cp -f $RESOURCES_PATH/branding/favicon.ico $CONDA_PYTHON_DIR"/site-packages/notebook/static/favicon.ico" 

# Configure git
RUN \
    git config --global core.fileMode false && \
    git config --global http.sslVerify false && \
    # Use store or credentialstore instead? timout == 365 days validity
    git config --global credential.helper 'cache --timeout=31540000'



# Create Desktop Icons for Tooling
COPY resources/icons $RESOURCES_PATH/icons

RUN \
    # glances:
    echo "[Desktop Entry]\nVersion=1.0\nType=Link\nName=Glances\nComment=Hardware Monitoring\nCategories=System;Utility;\nIcon=/resources/icons/glances-icon.png\nURL=http://localhost:8092/tools/glances" > /usr/share/applications/glances.desktop && \
    chmod +x /usr/share/applications/glances.desktop 
    # Remove mail and logout desktop icons

# Copy resources into workspace
COPY resources/tools $RESOURCES_PATH/tools
COPY resources/tests $RESOURCES_PATH/tests
COPY resources/tutorials $RESOURCES_PATH/tutorials
COPY resources/licenses $RESOURCES_PATH/licenses
COPY resources/reports $RESOURCES_PATH/reports

# Various configurations
RUN \
    touch $HOME/.ssh/config && \
    # clear chome init file - not needed since we load settings manually
    chmod -R a+rwx $WORKSPACE_HOME && \
    chmod -R a+rwx $RESOURCES_PATH && \
    # make all desktop launchers executable
    chmod -R a+rwx /usr/share/applications/ && \
    ln -s $RESOURCES_PATH/tools/ $HOME/Desktop/Tools && \
    ln -s $WORKSPACE_HOME $HOME/Desktop/workspace && \
    chmod a+rwx /usr/local/bin/start-notebook.sh && \
    chmod a+rwx /usr/local/bin/start.sh && \
    chmod a+rwx /usr/local/bin/start-singleuser.sh && \
    chown root:root /tmp && \
    chmod 1777 /tmp && \
    # TODO: does 1777 work fine? chmod a+rwx /tmp && \
    # Set /workspace as default directory to navigate to as root user
    echo 'cd '$WORKSPACE_HOME >> $HOME/.bashrc

# MKL and Hardware Optimization
# Fix problem with MKL with duplicated libiomp5: https://github.com/dmlc/xgboost/issues/1715
# Alternative - use openblas instead of Intel MKL: conda install -y nomkl
# http://markus-beuckelmann.de/blog/boosting-numpy-blas.html
# MKL:
# https://software.intel.com/en-us/articles/tips-to-improve-performance-for-popular-deep-learning-frameworks-on-multi-core-cpus
# https://github.com/intel/pytorch#bkm-on-xeon
# http://astroa.physics.metu.edu.tr/MANUALS/intel_ifc/mergedProjects/optaps_for/common/optaps_par_var.htm
# https://www.tensorflow.org/guide/performance/overview#tuning_mkl_for_the_best_performance
# https://software.intel.com/en-us/articles/maximize-tensorflow-performance-on-cpu-considerations-and-recommendations-for-inference
ENV KMP_DUPLICATE_LIB_OK="True" \
    # Control how to bind OpenMP* threads to physical processing units # verbose
    KMP_AFFINITY="granularity=fine,compact,1,0" \
    KMP_BLOCKTIME=0 \
    # KMP_BLOCKTIME="1" -> is not faster in my tests
    # TensorFlow uses less than half the RAM with tcmalloc relative to the default. - requires google-perftools
    # Too many issues: LD_PRELOAD="/usr/lib/libtcmalloc.so.4" \
    # TODO set PYTHONDONTWRITEBYTECODE
    # TODO set XDG_CONFIG_HOME, CLICOLOR?
    # https://software.intel.com/en-us/articles/getting-started-with-intel-optimization-for-mxnet
    # KMP_AFFINITY=granularity=fine, noduplicates,compact,1,0
    # MXNET_SUBGRAPH_BACKEND=MKLDNN
    # TODO: check https://github.com/oneapi-src/oneTBB/issues/190
    # TODO: https://github.com/pytorch/pytorch/issues/37377
    # use omp
    MKL_THREADING_LAYER=GNU \
    # To avoid over-subscription when using TBB, let the TBB schedulers use Inter Process Communication to coordinate:
    ENABLE_IPC=1 \
    # will cause pretty_errors to check if it is running in an interactive terminal
    PYTHON_PRETTY_ERRORS_ISATTY_ONLY=1 \
    # TODO: evaluate - Deactivate hdf5 file locking
    HDF5_USE_FILE_LOCKING=False

# Set default values for environment variables
ENV CONFIG_BACKUP_ENABLED="false" \
    SHUTDOWN_INACTIVE_KERNELS="false" \
    SHARED_LINKS_ENABLED="true" \
    AUTHENTICATE_VIA_JUPYTER="false" \
    DATA_ENVIRONMENT=$WORKSPACE_HOME"/environment" \
    WORKSPACE_BASE_URL="/" \
    INCLUDE_TUTORIALS="false" \
    # Main port used for sshl proxy -> can be changed
    WORKSPACE_PORT="8080" \
    # Set zsh as default shell (e.g. in jupyter)
    SHELL="/usr/bin/zsh" \
    # Fix dark blue color for ls command (unreadable):
    # https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
    # USE default LS_COLORS - Dont set LS COLORS - overwritten in zshrc
    # LS_COLORS="" \
    # set number of threads various programs should use, if not-set, it tries to use all
    # this can be problematic since docker restricts CPUs by stil showing all
    MAX_NUM_THREADS="auto"

### END CONFIGURATION ###
ENV WORKSPACE_VERSION=$ARG_WORKSPACE_VERSION
RUN unlink /opt/conda/lib/libtinfo.so.6 
RUN  chown -R root:root /usr/bin/su &&\
     chmod u+s /usr/bin/su &&\
    echo "ide@123\nide@123"|passwd root && mkdir -p /home/sdwot/Desktop && useradd -d /home/sdwot -s /bin/bash sdwot && echo "sdwot\nsdwot"|passwd sdwot && chown -R sdwot:sdwot /home/sdwot &&\
   su -c "mkdir /home/sdwot/logs" sdwot &&\
   chown -R sdwot:sdwot /home/sdwot 


ENTRYPOINT ["/tini", "-g", "--"]

CMD ["python", "/resources/docker-entrypoint.py"]


EXPOSE 8080
###
