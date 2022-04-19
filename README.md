# gene-222 HW 1

1. Configure your GCP+AWS accounts (10 points) [submit screenshots]

#### AWS
![screenshot of AWS configuration](./aws.png)

#### GCP
![screenshot of GCP configuration](./gcp.png)


2.
  a. This is an example of strong scaling because the workload remains the same but gets further distributed to multiple processes.
  b and c:
  
  
| Threads  | Time | Speedup | Efficiency | 
| -------- | ---- | ------- |------------|
| 1 | 750  | - | - |
| 2 | 410  | 1.8292 | 0.9146 | 
| 4 | 204  | 3.6765 | 0.9191 |
| 8 | 98   | 7.6531 | 0.9566 |
| 16| 63   | 11.9048| 0.74405 | 

 d. 8 threads is the most efficient configuration based off of the calculations in the table above. 
3. 
A. How do we show that we have successfully set up the docker commands?

B.

The Dockerfile is available [here](./Dockerfile). I ran the following commands to demonstrate that my bowtied configuration worked:
```
docker build -t bowtie.v1.3.0 .
docker run bowtie.v1.3.0 bowtie e_coli reads/e_coli_1000.fq > docker.log
```
The full output from the command is available in [docker.log](./docker.log)

4. List 5 Docker best practices:
 - Limit your build context: docker sends all of the files in your current working directory to the "build context" so you want to make sure your working directory where you're running builds doesn't have a ton of data in it.
 - Take advantage of the build cache: The docker container will cache the build up to the point where you most recently made changes. You can develop way more quickly if you get the "compmutationally heavy" part of the build done early on in the dockerfile so that it's more likely to remain cached as you're developing the image.
 - Start with the appropriate base image: many of the popular packages managers for bioinformatics software such as conda and bioconductor etc. have pre-built images that are optimized for a specific context. Rather than rebuild the wheel, use these images as your base-image
 - Don't store data in the image: you can rely on reference volumes to mount data files inside of the docker image. You want to keep the image itself as lightweight as possible.
 - Don't use the `latest` tag for production images: the point of Docker is for a process to be reproducible across different environments. If you use the `latest` tag for a base image, when the base image gets updated then your build will change. This can lead to some headaches. 


5. To do!
