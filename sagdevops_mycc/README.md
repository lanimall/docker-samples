# Some Custom SoftwareAG Command Central images

The SoftwareAG "Command Central" components are the core building blocks from which the rest of the SoftwareAG products can be provisioned.
This project creates some custom Docker images for the core Command Central components:
 - Command Central Server (CCE)
 - Command Central Agent (SPM)
 - Command Central CLI

**Notes:**
 - The OS for the images is Centos 7 ("centos:7" from docker-hub)
 - During image creation:
   - The OS is upgraded with latest fixes
   - The SoftwareAG software is pulled from central repository, installed, and all latest fixes applied.
 - The SoftwareAG processes will run as "saguser" (a non-root standard Linux user)

**My TODOs**
 - Reduce image size

For more open-source resources regarding SofwareAG DEVOPS, go to: [SoftwareAG OSS Repository on GitHub](https://github.com/SoftwareAG)

And specifcaly, the following github projects were instrumental in the creation of this sample project:
 - [sagdevops-antcc](https://github.com/SoftwareAG/sagdevops-antcc)
 - [sagdevops-cc-server](https://github.com/SoftwareAG/sagdevops-cc-server)
 - [sagdevops-ci-infra](https://github.com/SoftwareAG/sagdevops-ci-infra)

## Prerequisite: Set Env Variables in Shell

**For 10.0**

```bash
export CC_VERSION=10.0
export CC_IMAGE_PREFIX=your_prefix_lowercase
```

**For 9.12**

```bash
export CC_VERSION=9.12
export CC_IMAGE_PREFIX=your_prefix_lowercase
```

## Build the images:

### Build All

```bash
docker-compose build
```

### Build Command Central Server

```bash
docker-compose build cce
```

### Build Command Central Agent

```bash
docker-compose build spm
```

### Build Command Central Cli

```bash
docker-compose build cli
```

## Create and start instance from the images:

### Run Command Central Server

```bash
docker-compose start cce
```

### Run Command Central Agent

```bash
docker-compose start spm
```

### Run Command Central Cli

```bash
docker-compose start cli
```
