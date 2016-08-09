##nipype MultivariateTemplateConstruction

Working in Jupyter notebook: ants_test.ipynb. See Issues for to-do list

---

##Porting simplified multivariateTemplateConstruction into ANTsR

Scripts work and with a few tweaks, can make the multiple iterations automatic

Individual steps of template construction (registrations, applying transforms, averaging transformed images) in '/pieces'. Example run for multiple iterations of the linear and non-linear transforms in '/test_run'

Issues:

1. Problems with parallelizing using rslurm. Can't accommodate need to use the complete call of ANTs, where we want to use 3 moving images (label, T1 weighted, T2* weighted)
2. In average image script, environmental object of class ANTSimage <-> callable variable in script