# Julia for High-Performance Computing

A 3.5-day workshop that will take place in Stuttgart the [High Performance Computing Center Stuttgart (HLRS)](https://www.hlrs.de/) in September 2022.

**Course page:** https://www.hlrs.de/training/2022/julia   
**Instructor:** Carsten Bauer (PC2)   
**Organizers:** Michael Schlottke-Lakemper (HLRS), Carsten Bauer (PC2)

Hosted by the [High Performance Computing Center Stuttgart (HLRS)](https://www.hlrs.de/) and the [Paderborn Center for Parallel Computing (PC2)](https://pc2.uni-paderborn.de/).

## Tentative schedule

<a href="https://github.com/carstenbauer/JuliaHLRS22/raw/main/orga/schedule/schedule.pdf"><img src="https://github.com/carstenbauer/JuliaHLRS22/raw/main/orga/schedule/schedule.png" width=720px></a>

## Handout

I prepared a little [digital handout](https://github.com/carstenbauer/JuliaHLRS22/blob/main/orga/handout/handout.md) ([PDF version](https://github.com/carstenbauer/JuliaHLRS22/blob/main/orga/handout/handout.pdf)) for the course which contains some practical information about Hawk and the local machines. For example, it gives brief instructions on how to get an interactive compute-node session with Julia on the cluster.

## Preparing for the workshop (if you bring your own device)

### Software and workshop materials

What you need (in short):
  * [Julia 1.8](https://julialang.org/)
    * I recommend to use [juliaup](https://github.com/JuliaLang/juliaup) to install and manage Julia versions!
  * [Visual Studio Code](https://code.visualstudio.com/), including its [Julia Extension](https://www.julia-vscode.org/).
  * [Jupyter Lab](https://jupyter.org/) (technically optional, since VS Code can also open `.ipynb` files)
  * The workshop materials, i.e. this GitHub repository

**Note:** I might still change some of the workshop materials. To be on the safe side, make sure you update your local instance of the repository right before the start of the workshop. (You can always delete your local copy and redownload/`git pull`.)

### Instantiating & precompiling the Julia environment

Navigate to your local copy of this repository and run

```
julia install.jl
```

This will download all the necessary Julia (and a few Python) dependencies.

## Static HTML

In case you don't have Jupyter and just want to follow along: The folder [`HTML/`](https://github.com/carstenbauer/JuliaHLRS22/tree/main/HTML) contains all the main content (jupyter notebooks) in static HTML format.

## Try it out live! (Beta)

Click on the [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/carstenbauer/JuliaHLRS22-binder/main?urlpath=git-pull%3Frepo%3Dhttps%253A%252F%252Fgithub.com%252Fcarstenbauer%252FJuliaHLRS22%26urlpath%3Dtree%252FJuliaHLRS22%252F%26branch%3Dmain) badge to dive right into the workshop materials.
