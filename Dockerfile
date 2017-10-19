FROM google/cloud-sdk

# install edxcut dependency from github source, not pypi
RUN git clone https://github.com/mitodl/edxcut.git
RUN pip install ./edxcut

# install edx2bigquery
RUN git clone https://github.com/mitodl/edx2bigquery.git
WORKDIR /edx2bigquery
RUN python setup.py develop

WORKDIR /
