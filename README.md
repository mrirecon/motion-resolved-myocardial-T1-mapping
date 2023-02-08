
These scripts reproduce the experiments described in the article:

Xiaoqing Wang, Sebastian Rosenzweig, Volkert Roeloffs, Moritz Blumenthal, Nick Scholand, Zhengguo Tan, H. Christian M. Holme, Christina Unterberg-Buchwald, Rabea Hinkel and Martin Uecker.

Free-Breathing Myocardial T1 Mapping using Inversion-Recovery Radial FLASH and Motion-Resolved Model-Based Reconstruction.
Magnetic Resonance in Medicine: DOI: 10.1002/mrm.29521. [1,2]

The algorithms have been integrated into the Berkeley Advanced Reconstruction Toolbox (BART) [3] (commit 3f6ebb12).

The raw files are hosted on ZENODO and must be downloaded first:

    Manual download: 
        Part 1: https://doi.org/10.5281/zenodo.5707688
        Part 2: https://doi.org/10.5281/zenodo.7350323

    Download via script:
        All files: bash load_all.sh

After downloading, all raw data including ROIs are in the "data" folder.

The other folders contain:

    all_phantom.sh scripts, which performs single-slice and motion-resolved model-based image reconstruction for the experimental phantom data sets presented in the paper
    all_volunteer.sh scripts, which performs motion-resolved model-based image reconstructions for all volunteer data sets presented in the paper
    all_pig.sh scripts, which performs motion-resolved model-based image reconstructions for the experimental pig data set presented in the paper
    Figurex/Figurex.sh scripts, which create cfl files for the corresponding Figures and Videos.

The data can be viewed e.g. with 'view'[4] or be loaded into Matlab or Python using the wrappers provided in BART subdirectories './matlab' and './python'.

If you need further help to run the scripts, I am happy to help you: xwang106@mgh.harvard.edu / xiaoqingwang2010@gmail.com

[1]. https://arxiv.org/abs/2111.09398 [2]. https://onlinelibrary.wiley.com/doi/10.1002/mrm.29521 [3]. https://mrirecon.github.io/bart [4]. https://github.com/mrirecon/view

