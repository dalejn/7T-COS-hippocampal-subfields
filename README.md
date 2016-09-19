##nipype MultivariateTemplateConstruction

Working in Jupyter notebook: ants_test_slurm.ipynb. See Issues for to-do list

Rigid x3 <br />
Affine x2 <br />
Bspline x4 <br />
 <br />
9 total workflows

-------------------------------

##Porting simplified multivariateTemplateConstruction into ANTsR in multivariateTemplateConstruction.R

Using RStudio/0.98_3.2.3-9.1

Scripts work and with a few tweaks, can make the multiple iterations automatic.

Example run for multiple iterations of the linear (rigid and affine) and non-linear (BSplineSyN) transforms in '/test_run'

Issues:

1. Problems with parallelizing using rslurm. Can't accommodate need to use the complete call of ANTs, where we want to use 3 moving images (label, T1 weighted, T2* weighted)
2. In average image script, environmental object of class ANTSimage <-> callable variable in script