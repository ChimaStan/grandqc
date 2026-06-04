FROM condaforge/miniforge3:26.1.1-3

WORKDIR /app/grandqc

COPY environment.yml .

RUN mamba env create -f environment.yml && \
    mamba clean -afy

COPY . .

ENV PATH=/opt/conda/envs/grandqc/bin:$PATH

RUN echo "conda activate grandqc" >> ~/.bashrc

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "grandqc"]
CMD ["/bin/bash"]
