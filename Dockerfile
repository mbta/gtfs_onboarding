ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Frank LaNasa <fjlanasa@gmail.com>"

RUN conda install -c conda-forge ipython-sql=0.3.9

RUN conda install -c conda-forge pandas=1.1.3

RUN conda install -c conda-forge jupyter_contrib_nbextensions=0.5.1

RUN jupyter labextension install @jupyterlab/toc@4.0.0

COPY ["db.py", "./"]

RUN mkdir feed

RUN python db.py

COPY ["*.ipynb", "./"]

COPY ["img", "./img"]

ENV JUPYTER_ENABLE_LAB=1

CMD ["start-notebook.sh"]