# GCP Set Up

1. Create a pre-configured PyTorch VM such as [this one](https://cloud.google.com/ai-platform/deep-learning-vm/docs/pytorch_start_instance). If you hit issues with [quotas](https://cloud.google.com/compute/quotas), it may be because you're on the free trial:
    > If you're using the Google Cloud free trial, you can't request a change to your quota.
2. [Initialize `gcloud`](https://cloud.google.com/sdk/docs/quickstart) so you can SSH into your VM:
    ```shell script
    gcloud init
    ```
3. Upload the bare repo (strip any unnecessary data to save time):
    ```shell script
    gcloud compute scp --recurse ~/Developer/github.com/znxlwm/pytorch-generative-model-collections cmpe257-vm:~/ 
    ```
4. SSH into the VM:
    ```shell script
    gcloud compute ssh --project fleet-coyote-295106 --zone us-west1-a cmpe257-vm -- -L 8080:localhost:8080
    ```
5. Set up the VM by [installing the correct version of Python](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-python.html#installing-a-different-version-of-python) and [activating the environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#activate-env): 
    ```
    # Leave off the "anaconda" at the end if you're following the instructions at the URL above.
    conda create -n python3.5.2 python=3.5.2
    conda activate python3.5.2
    pip install -r requirements.txt
    python main.py --dataset fashion-mnist --gan_type GAN --epoch 50 --batch_size 64 --gpu_mode
    ```
6. [Set up matplotlib](https://stackoverflow.com/questions/37604289/tkinter-tclerror-no-display-name-and-no-display-environment-variable) to avoid an issue:
    ```shell
    echo "backend: Agg" > ~/.config/matplotlib/matplotlibrc
    ```
7. Download the results onto your machine:
    ```shell script
    gcloud compute scp --recurse cmpe257-vm:~/pytorch-generative-model-collections/results ~/Downloads
    ```