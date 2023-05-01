FROM 755674844232.dkr.ecr.us-east-1.amazonaws.com/spark/emr-6.4.0

LABEL org.opencontainers.image.source https://github.com/aws-samples/emr-serverless-samples
LABEL org.opencontainers.image.url https://github.com/aws-samples/emr-serverless-samples/tree/main/utilities/spark-ui
LABEL org.opencontainers.image.documentation https://github.com/aws-samples/emr-serverless-samples/blob/main/utilities/spark-ui/README.md

USER root
RUN ln -s /usr/share/aws/aws-java-sdk/aws-java-sdk-bundle-*.jar /usr/lib/spark/jars/
RUN ln -s /usr/share/aws/emr/emrfs/lib/emrfs-hadoop-assembly-*.jar /usr/lib/spark/jars/

ADD sparkHistory.sh /tmp/sparkHistory.sh
#ADD py_web_server.py /tmp/py_web_server.py
RUN chmod +x /tmp/sparkHistory.sh
#RUN chmod +x /tmp/py_web_server.py

RUN echo $'\n\
spark.eventLog.enabled                      true\n\
spark.history.ui.port                       18080\n\
spark.history.custom.executor.log.url       https://<YOUR_MASTER_ID>:9977/spark/logs/applications/00f7etp6vmd8cb09/jobs/00f7eu9k4bhk1409/{{CONTAINER_ID}}/{{FILE_NAME}}.gz\n\
' > /etc/spark/conf/spark-defaults.conf

EXPOSE 9977

RUN mkdir /mnt/s3 \
    && chown spark:spark /mnt/s3

USER spark:spark

ENV SPARK_NO_DAEMONIZE=true
ENTRYPOINT [ "/tmp/sparkHistory.sh" ]
