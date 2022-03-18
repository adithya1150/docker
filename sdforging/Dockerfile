FROM baseerp

ENV HOME=/home/sdwot/Desktop

RUN chown -R postgres:postgres /var/lib/postgresql /var/run/postgresql

USER postgres

RUN /usr/bin/dbrestart  && psql -c "create database sdforging owner sdwot;"

USER sdwot

RUN sed -i 's|/workspace/.ssh/|/home/sdwot/docker/|g' /home/sdwot/.ssh/config &&cd /home/sdwot/Desktop/sdwot &&git flow feature pull origin Saideepa && sed -i 's|/home/sdwot/docker/|/workspace/.ssh/|g' /home/sdwot/.ssh/config

ADD --chown=sdwot:sdwot data /home/sdwot/erp/data 
RUN --mount=type=bind,target=/database/ echo "postgres"|su -c "/usr/bin/dbstart" postgres &&\
    PGPASSWORD=sdwot psql -h localhost -U sdwot  sdforging < /database/sdforging.sql &&\
    PGPASSWORD=sdwot psql -h localhost -U sdwot -d sdforging -c "update res_users set password ='admin' where id=2;"&&\
    echo "/home/sdwot/erp/bin/python /home/sdwot/Desktop/sdwot/sdwot.py  -c /home/sdwot/erp/.erp_serverrc -u all -d sdforging&" > /home/sdwot/erp/update.sh &&\
    echo "/home/sdwot/erp/bin/python /home/sdwot/Desktop/sdwot/sdwot.py  -c /home/sdwot/erp/.erp_serverrc&" > /home/sdwot/erp/start.sh &&\
    chmod + /home/sdwot/erp/update.sh /home/sdwot/erp/start.sh&& sh /home/sdwot/erp/update.sh && /usr/bin/sleep 900

USER root

ENV HOME=/root

