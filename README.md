# ToyEMS

This repo proposes a toy example of Energy Management System (EMS)

## Required

Julia 0.6.4

## Use Docker

You can use the provided Dockerfile to build an image set up for Julia and Jupyter

0. install Docker
1. build the image `julia-0.6.4` by typing ```docker build -t julia-0.6.4 .``` in the directory
2. launch the Docker container  ```docker run -i -t --rm -p 8888:8888 -v /home/your-working-directory:/home/jovyan/work  julia-1.0.0 /bin/bash```

Because of the `--rm` flag, the container will be deleted when you exit it (ctrl+q) and you need to run it again when you start working on your project. Inside the container, you can launch a Jupyter Notebook ```jupyter notebook --no-browser --ip=0.0.0.0 --notebook-dir=/home/jovyan/work/ --allow-root``` and access it in your browser at ```localhost:8888```
