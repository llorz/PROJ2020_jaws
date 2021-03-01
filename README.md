# Geometric analysis of shape variability of lower jaws of prehistoric humans
This is an example code for the paper "Geometric analysis of shape variability of lower jaws of prehistoric humans" by Jing Ren, Peter Wonka, Gowtham Harihara, and Maks Ovsjanikov. 
The paper can be found [here](https://www.sciencedirect.com/science/article/abs/pii/S0003552120301035).


Dataset
--------------------
The dataset consists of 10 jaws of prehistoric humans from the anthropologists and we visualize them below. 
We provide the [original dataset](https://github.com/llorz/PROJ2020_jaws/tree/main/Dataset/original/vtx_5k) 
and the [remodelled dataset](https://github.com/llorz/PROJ2020_jaws/tree/main/Dataset/remodelled/vtx_5k)
where we clean the dataset a bit to remove outliers, fix holes, etc. The analysis is done on both datasets. 


<p align="center">
  <img align="center"  src="/figures/dataset.png"  width=800>
</p>


Dense correspondences
--------------------
We use [functional map pipeline with BCICP refinement](https://github.com/llorz/SGA18_orientation_BCICP_code) method to compute dense
correspondences between every pair of jaws in the dataset. Below we visualize the map via color transfer (the corresponding regions have the same color). 
The computed maps are saved in the `Dataset` folder. 

See [`run_compute_maps.m`](https://github.com/llorz/PROJ2020_jaws/blob/main/run_compute_maps.m) to see the **paramters** for map computation.

Alternatively, one can try the [ZoomOut](https://github.com/llorz/SGA19_zoomOut) method to efficiently refine the computed maps. 

<p align="center">
  <img align="center"  src="/figures/maps.png"  width=800>
</p>


Shape deformation
--------------------
We deform on shape into another and use the corresponding transformation to define the shape similarity between the shape pair for shape analysis. 
See [`run_nonRigidMatching`](https://github.com/llorz/PROJ2020_jaws/blob/main/run_nonRigidMatching.m) for more details. 
<p align="center">
  <img align="center"  src="/figures/deformation.png"  width=400>
</p>


Below we visualize the deformation over iterations. 
<p align="center">
<video controls="controls" width="800" height="600" src="/figures/all_jaws_to_sapiens_720p.mov"></video>
</p>
