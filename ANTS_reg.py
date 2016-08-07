from os.path import join as opj
from nipype.interfaces.ants import Registration

antsreg = Registration()
antsreg.inputs.float = True
antsreg.inputs.collapse_output_transforms=True
antsreg.inputs.fixed_image=['lhtemplate0.nii.gz','lhtemplate1.nii.gz','lhtemplate2.nii.gz']
antsreg.inputs.moving_image=['d701-lab.nii.gz','d701-t1-mask.nii.gz','d701-t2-bfc-mask.nii.gz']
antsreg.inputs.initial_moving_transform_com=1
antsreg.inputs.num_threads=1
antsreg.inputs.output_inverse_warped_image=True
antsreg.inputs.output_warped_image=True
antsreg.inputs.sigma_units=['vox']*3
antsreg.inputs.transforms=['Rigid', 'Affine', 'BSplineSyN']
antsreg.inputs.terminal_output='test'
antsreg.inputs.winsorize_lower_quantile=0.005
antsreg.inputs.winsorize_upper_quantile=0.995
antsreg.inputs.convergence_threshold=[1e-06]
antsreg.inputs.convergence_window_size=[10]
antsreg.inputs.metric=['MI', 'MI', 'CC']
antsreg.inputs.metric_weight=[1.0]*3
antsreg.inputs.number_of_iterations=[[1000, 500, 250, 0],
                      [1000, 500, 250, 0],
                      [100, 100, 70, 50, 0]]
antsreg.inputs.radius_or_number_of_bins=[32]*3
antsreg.inputs.sampling_percentage=[0.25, 0.25, 1]
antsreg.inputs.sampling_strategy=['Regular',
                   'Regular',
                   'None']
antsreg.inputs.shrink_factors=[[6, 4, 2, 1],
                [6, 4, 2, 1],
                [10, 6, 4, 3, 1]]
antsreg.inputs.smoothing_sigmas=[[4, 2, 1, 0],
                  [4, 2, 1, 0],
                  [5, 3, 2, 1, 0]]
antsreg.inputs.transform_parameters=[(0.1,),
                      (0.1,),
                      (0.1, 26, 0.0, 3.0)]
antsreg.inputs.use_histogram_matching=True
antsreg.inputs.write_composite_transform=True

antsreg.cmdline
