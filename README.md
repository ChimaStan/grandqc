


<div align="center">
  <img src="Figures/logo.png" width="600"/>
  <div>&nbsp;</div>

</div>

<div align="center">
    <img src="Figures/merge1.gif" height="200" width="500px"/>
    <img src="Figures/merge2.gif" height="200" width="500px"/>
</div>

# GrandQC

## A comprehensive solution to quality control problem in digital pathology

*Nature Communications*

 [Journal Link](https://www.nature.com/articles/s41467-024-54769-y) | [Open Access Read Link](https://rdcu.be/d3I7H) | [Download TISSUE Model](https://zenodo.org/records/14507273) | [Download ARTIFACT Models](https://zenodo.org/records/14041538) | [Cite](#Citation) 

[QC Masks to TCGA cohorts](https://zenodo.org/records/14041578)

**Abstract:** Histological slides contain numerous artifacts that can significantly deteriorate the performance of image analysis algorithms. Here we develop the GrandQC tool for tissue and multi-class artifact segmentation. GrandQC allows for high-precision tissue segmentation (Dice score 0.957) and segmentation of tissue without artifacts (Dice score 0.919–0.938 dependent on magnification). Slides from 19 international pathology departments digitized with the most common scanning systems, and from The Cancer Genome Atlas dataset were used to establish a QC benchmark, analyzing inter-institutional, intra-institutional, temporal, and inter-scanner slide quality variations. GrandQC improves the performance of downstream image analysis algorithms. We open-source the GrandQC tool, our large manually annotated test dataset, and all QC masks for the entire TCGA cohort to address the problem of QC in digital/computational pathology. GrandQC can be used as a tool to monitor sample preparation and scanning quality in pathology departments and help to track and eliminate major artifact sources.

## Fork Notice

This repository is a fork of the original [GrandQC project](https://github.com/cpath-ukk/grandqc).

The modifications in this fork include:

- Addition of a Conda environment specification (`environment.yml`)
- Containerisation via Docker
- Automated container publishing GHCR
- Added automatic device backend detection (CUDA, MPS, or CPU)
- Improved tissue mask loading robustness by explicitly loading tissue detection masks in 8-bit grayscale mode prior to resizing and multi-class artifact segmentation.

Please refer to the original publication and repository for the primary GrandQC methodology and scientific validation.

## Introduction

### Overview

GrandQC is an open-source tissue and multi-class artifact segmentation toolbox based on PyTorch.

The main branch works with **PyTorch 2+**. 

<details open>
<summary>Major features</summary>

- **GrandQC Design**

  GrandQC is composed of two components: tissue segmentation and artifact segmentation. Tissue segmentation serves as the foundation for artifact segmentation, offering a more precise tissue target for detecting artifacts

- **Comprehensive Artifact Segmentation**

  GrandQC offers advanced detection of all common artifacts on segmented whole slide images (WSI), including tissue folding, pen marks, bubbles, edges, black spots, foreign objects, and out-of-focus areas. This level of coverage surpasses that of any existing open-source quality control tools.

- **High efficiency**

  For tissue segmentation, GrandQC processes a whole slide image (WSI) in an average of 0.4 seconds. Artifact segmentation takes between 27 and 45 seconds per WSI, depending on the model and magnification level.

- **Models with Different Magnifications**

  To balance efficiency and segmentation quality, GrandQC offers three models trained at different magnifications: **5x, 7x, and 10x**. Higher magnifications result in more accurate artifact segmentation but require longer processing times.

- **State of the art**

  We performed an extensive comparison with existing open-source tools, demonstrating that GrandQC significantly outperforms them across multiple metrics.

- **Building a Benchmark**
  
  We analyzed whole slide images (WSI) from various institutions and hospitals across different countries to develop a comprehensive quality benchmark. This benchmark enables each hospital and institution to evaluate their tissue slide preparation processes and make targeted improvements.

- **Scanner Selection Assistant**
  
  GrandQC allows for direct comparison of different scanners by analyzing the same batch of tissue slides. This helps in identifying the strengths and weaknesses of each scanner, particularly in relation to out-of-focus issues.

</details>

### UPDATE

- **06.03.2025:** A new function has been added for generating GeoJSON files, refer to the section [How to run the scripts](#how-to-run-the-scripts)

### Model selection

To balance accuracy and inference efficiency, we have trained three different models based on three magnifications (5x, 7x, and 10x). As the magnification decreases, the inference speed increases, but accuracy may be slightly affected. 

We consider 7x model to be an optimal choice for most applications.

Please refer to publication for results of formal validation (pixel-wise segmentation accuracy) for 5x, 7x, and 10x GrandQC versions. 

Here is an example of one ROI(Region of Interest) image from one Whole Slide Image:

<div align="center">
  <img width="80%" alt="ROI and slide classification results" src="Figures/img.png">
</div>

### Model Output (Pixel class coding / Class Labels)

*The numbers in brackets correspond to each class*

GrandQC TISSUE models segmentt tissue (0) and background (1).

GrandQC ARTIFACT models segment tissue (1), background (7), and five different types of artifacts, including: Tissue folds (2), Dark spots & Foreign objects (3), Pen markings (4), Air Bubble & Slide Edge artifacts (5), and Out-of-focus artifacts (6). 

In the final model output, white represents tissue, black represents background, 
and the five types of artifacts are displayed in distinct colors, as shown in the example below.

<div align="center">
  <img width="80%" alt="ROI and slide classification results" src="Figures/img2.png">
</div>

## Installation
### Option 1: Local installation

```bash
git clone https://github.com/chimastan/grandqc.git
cd grandqc

conda env create -f environment.yml
conda activate grandqc
```

### Option 2: Containerised installation (recommended)

The containerised installation includes all GrandQC dependencies and can be used without creating a local Conda environment.

#### Docker

Pull the latest container:

```bash
docker pull ghcr.io/chimastan/grandqc:latest
```

#### Singularity/Apptainer

On HPC systems where Docker is not available, the GHCR Docker image can be converted to a Singularity/Apptainer image.

With Apptainer:

```bash
apptainer pull grandqc_latest.sif docker://ghcr.io/chimastan/grandqc:latest
```

or with Singularity:

```bash
singularity pull grandqc_latest.sif docker://ghcr.io/chimastan/grandqc:latest
```

Once inside the container, navigate to the relevant GrandQC inference folder and run the tissue or artifact segmentation scripts as described below.

## Models Download and Folder Structure 

**Links to download model checkpoints**: 

NOTE: the intended use of the GrandQC is firstly running a tissue segmentation model and then running artifact segmentation model.
Although the artifact segmentation models also can detect background, the tissue segmentation model does it much quicker (at 1x magnification), within seconds.

Tissue Segmentation Model: [Model](https://zenodo.org/records/14507273)

Artifact Segmentation Models: [Models](https://zenodo.org/records/14041538)


The final folder structure is as follows:

```plaintext

grandqc
├── 01_WSI_inference_OPENSLIDE_QC   
│   ├── models
│   │    ├── qc
│   │    │   ├── GrandQC_MPP1.pth
│   │    │   ├── GrandQC_MPP15.pth
│   │    │   └── GrandQC_MPP2.pth 
│   │    └── td
│   │        └── Tissue_Detection_MPP10.pth 
│   ├── main.py
│   ├── run_art.sh
│   └── ...
├── 02_WSI_inference_OME_TIFF_QC
│   ├── models
│   │    ├── qc
│   │    │   ├── GrandQC_MPP1.pth
│   │    │   ├── GrandQC_MPP15.pth
│   │    │   └── GrandQC_MPP2.pth 
│   │    └── td
│   │        └── Tissue_Detection_MPP10.pth 
│   ├── main.py
│   ├── run_art.sh
│   └── ...
├── requirements.txt
└── README.md
```

## How to use different model versions (5x ,7x, 10x)

The default version is 7x (Checkpoint: GrandQC_MPP15.pth)

For 5x, use:

```commandline
QC_MPP_MODEL=2.0
```
For 10x, use:

```commandline
QC_MPP_MODEL=1.0
```

## How to run the scripts

GrandQC inference is usually run in two stages:

1. **Tissue segmentation** using `wsi_tis_detect.py`
2. **Multi-class artifact segmentation** using `main.py`

The tissue segmentation step should be run first because the artifact segmentation step uses the tissue detection mask produced by the first stage. The same `OUTPUT_DIR` should usually be used for both steps.

For reference, see the sample bash scripts `run_tis.sh` and `run_art.sh`.

### Command-line arguments

#### Tissue segmentation: `wsi_tis_detect.py`

```bash
python wsi_tis_detect.py \
    --slide_folder "$SLIDE_FOLDER" \
    --output_dir "$OUTPUT_DIR"
```

Arguments:

* `--slide_folder`: Path to the folder containing the input whole-slide images.
* `--output_dir`: Path to the folder where tissue segmentation outputs will be saved.

#### Multi-class artifact segmentation: `main.py`

```bash
python main.py \
    --slide_folder "$SLIDE_FOLDER" \
    --output_dir "$OUTPUT_DIR" \
    --create_geojson "$CREATE_GEOJSON" \
    --mpp_model "$QC_MPP_MODEL"
```

Arguments:

* `--slide_folder`: Path to the folder containing the input whole-slide images.
* `--output_dir`: Path to the output folder. This should usually be the same output directory used for tissue segmentation.
* `--create_geojson`: Whether to create GeoJSON output files for QC results. The default is `"Y"`.
* `--mpp_model`: MPP value of the artifact segmentation model. The allowed values are `2.0`, `1.5`, and `1.0`. Use `2.0` for the 5x model, `1.5` for the 7x model, and `1.0` for the 10x model. The default is `1.5`.
* `--start`: Start index of the WSI list to process. This is useful for processing a subset of slides. The default is `0`.
* `--end`: End index of the WSI list to process. The default is `-1`.
* `--ol_factor`: Reduction factor for the overlay image relative to the original WSI dimensions. Larger values produce smaller overlay images. The default is `10`.

### Running locally

#### OpenSlide-supported WSIs

For OpenSlide-supported WSI formats such as `.svs`, `.ndpi`, and OpenSlide-readable `.tiff` files, use the scripts in `01_WSI_inference_OPENSLIDE_QC`:

```bash
cd 01_WSI_inference_OPENSLIDE_QC
```

Run tissue segmentation followed by multi-class artifact segmentation:

```bash
SLIDE_FOLDER="/path/to/the/slides/"
OUTPUT_DIR="/path/to/the/output/"
QC_MPP_MODEL=1.5
CREATE_GEOJSON="Y"

python wsi_tis_detect.py \
    --slide_folder "$SLIDE_FOLDER" \
    --output_dir "$OUTPUT_DIR"

python main.py \
    --slide_folder "$SLIDE_FOLDER" \
    --output_dir "$OUTPUT_DIR" \
    --create_geojson "$CREATE_GEOJSON" \
    --mpp_model "$QC_MPP_MODEL"
```

#### OME-TIFF WSIs

For OME-TIFF files, use the scripts in `02_WSI_inference_OME_TIFF_QC`:

```bash
cd 02_WSI_inference_OME_TIFF_QC
```

Run tissue segmentation followed by multi-class artifact segmentation:

```bash
SLIDE_FOLDER="/path/to/the/ome_tiff/slides/"
OUTPUT_DIR="/path/to/the/output/"
QC_MPP_MODEL=1.5
CREATE_GEOJSON="Y"

python wsi_tis_detect.py \
    --slide_folder "$SLIDE_FOLDER" \
    --output_dir "$OUTPUT_DIR"

python main.py \
    --slide_folder "$SLIDE_FOLDER" \
    --output_dir "$OUTPUT_DIR" \
    --create_geojson "$CREATE_GEOJSON" \
    --mpp_model "$QC_MPP_MODEL"
```

### Running with Docker

The examples below mount local slide and output folders into the container as `/slides` and `/output`.

#### OpenSlide-supported WSIs with Docker

```bash
docker run --rm -it \
    -v /path/to/the/slides:/slides \
    -v /path/to/the/output:/output \
    ghcr.io/chimastan/grandqc:latest \
    bash -lc '
        cd 01_WSI_inference_OPENSLIDE_QC

        SLIDE_FOLDER="/slides"
        OUTPUT_DIR="/output"
        QC_MPP_MODEL=1.5
        CREATE_GEOJSON="Y"

        python wsi_tis_detect.py \
            --slide_folder "$SLIDE_FOLDER" \
            --output_dir "$OUTPUT_DIR"

        python main.py \
            --slide_folder "$SLIDE_FOLDER" \
            --output_dir "$OUTPUT_DIR" \
            --create_geojson "$CREATE_GEOJSON" \
            --mpp_model "$QC_MPP_MODEL"
    '
```

#### OME-TIFF WSIs with Docker

```bash
docker run --rm -it \
    -v /path/to/the/ome_tiff/slides:/slides \
    -v /path/to/the/output:/output \
    ghcr.io/chimastan/grandqc:latest \
    bash -lc '
        cd 02_WSI_inference_OME_TIFF_QC

        SLIDE_FOLDER="/slides"
        OUTPUT_DIR="/output"
        QC_MPP_MODEL=1.5
        CREATE_GEOJSON="Y"

        python wsi_tis_detect.py \
            --slide_folder "$SLIDE_FOLDER" \
            --output_dir "$OUTPUT_DIR"

        python main.py \
            --slide_folder "$SLIDE_FOLDER" \
            --output_dir "$OUTPUT_DIR" \
            --create_geojson "$CREATE_GEOJSON" \
            --mpp_model "$QC_MPP_MODEL"
    '
```

### Running with Singularity/Apptainer

The Docker examples above can also be run with Singularity or Apptainer after pulling the `.sif` image.

For example, the Docker command pattern:

```bash
docker run --rm -it \
    -v /path/to/the/slides:/slides \
    -v /path/to/the/output:/output \
    ghcr.io/chimastan/grandqc:latest \
    bash -lc '<commands>'
```

is equivalent to the Apptainer pattern:

```bash
apptainer exec \
    --bind /path/to/the/slides:/slides \
    --bind /path/to/the/output:/output \
    grandqc_latest.sif \
    bash -lc '
    cd /app/grandqc/
    
    <commands>
    '
```

The same can be run with `singularity exec` instead of `apptainer exec` on systems using Singularity.

## Integration in other packages

If you want to integrate GrandQC into your package, you must do the following:

1.	Citation / attribution
   
Wherever your package references, bundles, or uses GrandQC (documentation, README, CLI help, UI, and/or source code comments), include a clear and unambiguous statement specifying how to cite GrandQC (provide the exact citation text and/or a link to the official citation instructions).
	
2.	License notice

Include a clear and unambiguous statement that GrandQC is distributed under a non-commercial license, and that use is subject to the terms of the original GrandQC license (link to the original license text).

## Citation

If you use GrandQC or benchmark in your research, please cite our [paper](https://www.nature.com/articles/s41467-024-54769-y)

Weng Z. et al. "GrandQC: a comprehensive solution to quality control problem in digital pathology"

Nature Communications (2024). https://doi.org/10.1038/s41467-024-54769-y

```
@article{Weng2024,
  author = {Weng, Zhilong and Seper, Alexander and Pryalukhin, Alexey and Mairinger, Fabian and Wickenhauser, Claudia and Bauer, Marcus and Glamann, Lennert and Bläker, Hendrik and Lingscheidt, Thomas and Hulla, Wolfgang and Jonigk, Danny and Schallenberg, Simon and Bychkov, Andrey and Fukuoka, Junya and Braun, Martin and Schömig-Markiefka, Birgid and Klein, Sebastian and Thiel, Andreas and Bozek, Katarzyna and Netto, George J. and Quaas, Alexander and Büttner, Reinhard and Tolkach, Yuri},
  title = {GrandQC: A comprehensive solution to quality control problem in digital pathology},
  journal = {Nature Communications},
  year = {2024},
  pages = {10685},
  doi = {10.1038/s41467-024-54769-y},
  url = {https://doi.org/10.1038/s41467-024-54769-y},
  issn = {2041-1723}
  }
```

## License

This project is released under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).
