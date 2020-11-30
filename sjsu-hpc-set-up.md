# SJSU HPC System Set Up

This guide demonstrates how to set up your environment on the SJSU HPC system to run the app.

## Authenticate through the SJSU VPN

Route your traffic through the SJSU VPN by following the instructions in *How to Connect to VPN using Cisco AnyConnect* for [macOS](https://www.sjsu.edu/it/docs/connectivity/How%20to%20Connect%20to%20VPN%20Using%20Cisco%20AnyConnect-For%20Macs-Students.pdf) or [Windows](https://www.sjsu.edu/it/docs/connectivity/How%20to%20Connect%20to%20VPN%20Using%20Cisco%20AnyConnect-For%20Windows-Students.pdf).

## Access the SJSU HPC System

Open a shell on the HPC system by following the instructions within the *How to Access the HPC* section of [*HPC Access Instructions*](http://coe-hpc-web.sjsu.edu). For instance, via a Unix-style terminal (take caution to replace `$SJSU_ID` with your numeric SJSU ID):

```shell script
ssh $SJSU_ID@coe-hpc1.sjsu.edu
```

## Clone this Repo

Clone this repo to the HPC system and change into its directory:

```shell script
git clone https://github.com/AndrewSelviaSJSU/pytorch-generative-model-collections.git
cd pytorch-generative-model-collections
```

## Configure a Virtual Environment

In order to run the app, you will need to configure a virtual environment with the required packages installed. Briefly read through [*HPC Access Instructions*](http://coe-hpc-web.sjsu.edu) to understand some of the intricacies of working on the HPC system. To begin with, read through the *Modular Software* section which you can utilize to set up the specific Python version required for this app to work:

```shell script
module load python3/3.5.6
``` 

Next, create a virtual environment and activate it:

```shell script
virtualenv venv
source venv/bin/activate
```

The required packages have already been enumerated in [`requirements.txt`](requirements.txt), so you just need to install them now:

```shell script
pip install -r requirements.txt
```

## Configure `matplotlib`

If you attempt to run the app now, you will hit an error like this:

```
Traceback (most recent call last):
  ...
  File "/opt/ohpc/pub/apps/python3/3.5.6/lib/python3.5/tkinter/__init__.py", line 35, in <module>
    import _tkinter # If this fails your Python may not be configured for Tk
ImportError: No module named '_tkinter'
```

Refer to [this StackOverflow discussion](https://stackoverflow.com/questions/37604289/tkinter-tclerror-no-display-name-and-no-display-environment-variable) which describes how to resolve it with: 

```shell script
echo "backend: Agg" > ~/.config/matplotlib/matplotlibrc
```

## Download the Data

The app should now run on the CPU, but recall that you're on the login node used by **all** other users. The *Accessing HPC Resources* section of the official documentation provides the motivation for running your software in batch mode instead:

> This node can be used to write scripts and code, compile programs, test execution of your programs on small data. However, it should not ever be used for large-scale computation, as it will negatively impact the ability of other users to access and use the HPC system. Instead, users should schedule jobs to be executed by slurm in batch mode when resources become available (preferred) or request interactive resources to use for executing necessary computations.

Furthermore, this app's performance is severely constrained when run on a CPU since it trains deep neural networks. Leveraging a GPU will improve its performance by 98%! If you attempt to run the app on a GPU immediately, though, you will encounter an issue since it presumes presence of the data locally. Since the data is not present yet, the app will fallback to fetching it from the Internet. Of course, the GPU cannot perform this operation, so you must perform it prior to running the app on the GPU. The following command leverages the app's own fallback logic defined [`dataloader.py`](dataloader.py):

```shell script
python -c "from dataloader import dataloader; dataloader('fashion-mnist', 28, 64)"
```

## Run the App

Finally, you should be able to run the app. As mentioned above, you should run it *on a GPU* and *in batch mode*. Luckily, such a configuration has been provided in [`e-in-style.sh`](e-in-style.sh). For usability, you are encouraged to add this line to the slurm preface in [`e-in-style.sh`](e-in-style.sh), taking caution to replace `$USERNAME` with your SJSU username:

```shell script
#SBATCH --mail-user=$USERNAME@sjsu.edu
``` 

Adding that line will send an email to you upon completion of the job.

Once you are ready to actually run the app, you can submit it to slurm via:

```shell script
sbatch --export=ALL,GAN_TYPE=GAN e-in-style.sh
```

The `--export=ALL,GAN_TYPE=GAN` parameter simply defines which type of GAN to train. You can choose from these ten options:

1. ACGAN
2. BEGAN
3. CGAN
4. DRAGAN
5. EBGAN
6. GAN
7. infoGAN
8. LSGAN
9. WGAN
10. WGAN_GP

### Run the Wrapper App

For convenience, you can also take advantage of the [`e-in-style-wrapper.scala`](e-in-style-wrapper.scala) app which simply runs runs the app for each of the 10 GANs concurrently on separate GPUs. The results will not conflict. This can save you time and eliminate potential user errors.

Unfortunately, since you likely do not have `sudo` privileges on the HPC system, you can't just turn this into a shell script. Therefore, the logic has just been wrapped inside a Scala app to circumvent this restriction. Scala installation is left as an exercise (suggestion: [use SDKMAN!](https://sdkman.io/sdks#scala)). Once it is configured, you can run the wrapper app via:

```shell script
scala e-in-style-wrapper.scala
```

## Track a Job

To track the status of a job, use `squeue`. Utilize the `-u` parameter to isolate *your* jobs:

```shell script
squeue -u $USER
```

## Cancel a Job

To cancel a running job, pass the job's identifier to `scancel`:

```shell script
$ squeue -u $USER
    JOBID PARTITION NAME      USER      ST  TIME  NODES NODELIST(REASON)
    29773 gpu       e-in-sty  123456789 R   2:09  1     g5
$ scancel 29773
```

## Retrieve the Results

Once a job completes, its output files should be written by default to the `results` & `models` directories. To retrieve them to your local machine, use `scp` (take caution to define `SJSU_ID` as your numeric SJSU ID like you did with `ssh` initially) from a shell on your **local** machine:

```shell script
SJSU_ID=123456789
scp -r $SJSU_ID@coe-hpc1.sjsu.edu:~/pytorch-generative-model-collections/results ~/Downloads/results
scp -r $SJSU_ID@coe-hpc1.sjsu.edu:~/pytorch-generative-model-collections/models ~/Downloads/models
```