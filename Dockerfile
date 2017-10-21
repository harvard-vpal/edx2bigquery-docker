FROM google/cloud-sdk

# install edxcut dependency from github source, not pypi
RUN git clone https://github.com/mitodl/edxcut.git
RUN pip install ./edxcut

# install pandas
RUN pip install pandas

# download edx2bigquery from github
RUN git clone https://github.com/mitodl/edx2bigquery.git

# install edx2bigquery
WORKDIR /edx2bigquery
RUN python setup.py develop

# set default working directory
RUN mkdir /edx_data
WORKDIR /edx_data
