#Install and setup the docker image
FROM python:3.7-alpine3.7
RUN echo "http://dl-4.alpinelinux.org/alpine/v3.7/main" >> /etc/apk/repositories && \
    echo "http://dl-4.alpinelinux.org/alpine/v3.7/community" >> /etc/apk/repositories
RUN apk update
RUN apk add chromium chromium-chromedriver 
#RUN apk add bash
RUN adduser -D scrapper
EXPOSE 5057

#Copy files into the docker image
COPY ./requirements.txt /root/requirements.txt 
ADD . /scrape-linkedin-selenium/

#Install dependencies 
RUN mkdir -p /linkedin/ \
  && pip install --upgrade pip \
  && pip install -r /root/requirements.txt \
  && cd /scrape-linkedin-selenium \
  && python3 setup.py install \
  && pip install fastapi uvicorn pydantic

#user management
WORKDIR /linkedin/
RUN chown -R scrapper:scrapper ./
USER scrapper


COPY api.py /linkedin/
ENV LI_AT AQEDAQzZQt0Dm3BeAAABdbbSwNQAAAF2BAsix04AhtA7a6ihL0IcaYSVOOcMSL-teAHhLzGlnzTK4MH1T-nPaxdAcUQDHCK6ENW5s51Sq3OWEmxud6mnldbUEVcBBeBxRa0z_LBF6hA2znjw8K0uHdXe
CMD uvicorn api:app --host 0.0.0.0 --port 5057
  


