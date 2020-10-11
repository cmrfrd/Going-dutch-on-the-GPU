import fire
import torch
from time import sleep

dtype = torch.long
gpu = torch.device("cuda:0")
cpu = torch.device("cpu")

def increase_entropy_of_universe(iterations=10, delay=0.5):
    """Simple function to compute cross entropy of two normal matrices"""

    # creating loss func
    loss = torch.nn.CrossEntropyLoss()

    for i in range(iterations):

        # compute loss
        input = torch.randn(3, 5).to(gpu)
        target = torch.empty(3, dtype=dtype).random_(5).to(gpu)
        output = loss(input, target)

        print(f"Iter: {i} - Result: {output}")

        sleep(delay)

if __name__ == "__main__":
    fire.Fire(increase_entropy_of_universe)
