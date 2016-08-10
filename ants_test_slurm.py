
# coding: utf-8

# In[1]:

# Import modules and set experiment-specific parameters
import copy
import os
from os.path import join as opj
from nipype.pipeline.engine import Workflow, Node, MapNode
from nipype.interfaces.io import SelectFiles, DataSink
from nipype.interfaces.utility import IdentityInterface
from nipype.interfaces.ants import Registration
from nipype import config, logging

config.enable_debug_mode()
logging.update_logging(config)

filepath = os.path.dirname( os.path.realpath( '__file__'))
datadir = os.path.realpath(os.path.join(filepath, ''))
os.chdir(datadir)

subject_list = ['d701', 'd702', 'd703', 'd704', 'd705', 'd706', 'd707', 
                'd708', 'd709', 'd710', 'd711', 'd712', 'd713', 'd714', 
                'd715', 'd716', 'd717', 'd720', 'd722', 'd723', 'd724', 
                'd726', 'd727', 'd728', 'd729', 'd730', 'd731', 'd732', 
                'd734']


# In[2]:

# Rigid Reg node 1

antsreg = Registration()
antsreg.inputs.float = True
antsreg.inputs.collapse_output_transforms=True

antsreg.inputs.fixed_image=[]
antsreg.inputs.moving_image=[]
antsreg.inputs.initial_moving_transform_com=1
antsreg.inputs.num_threads=1
antsreg.inputs.output_warped_image=True

antsreg.inputs.transforms=['Rigid']
antsreg.inputs.terminal_output='stream'
antsreg.inputs.winsorize_lower_quantile=0.005
antsreg.inputs.winsorize_upper_quantile=0.995
antsreg.inputs.convergence_threshold=[1e-06]
antsreg.inputs.convergence_window_size=[10]
antsreg.inputs.metric=[['MeanSquares','MI','MI']]
antsreg.inputs.metric_weight=[[0.75,0.125,0.125]]
                              
antsreg.inputs.number_of_iterations=[[1000, 500, 250, 0]]
antsreg.inputs.smoothing_sigmas=[[4, 3, 2, 1]]
antsreg.inputs.sigma_units=['vox']
antsreg.inputs.radius_or_number_of_bins=[[0,32,32]]

antsreg.inputs.sampling_strategy=[['None',
                               'Regular',
                               'Regular']]
antsreg.inputs.sampling_percentage=[[0,0.25,0.25]]

antsreg.inputs.shrink_factors=[[12,8,4,2]]

antsreg.inputs.transform_parameters=[[(0.1)]]

antsreg.inputs.use_histogram_matching=True
antsreg.inputs.write_composite_transform=True

antsreg_rigid = Node(antsreg,name='test_antsreg_rigid')
antsreg.cmdline


# In[14]:

# Apply Rigid Reg node 1

#from nipype.interfaces.ants import ApplyTransforms
#apply_rigid_reg = ApplyTransforms()
#apply_rigid_reg.inputs.dimension = 3
#apply_rigid_reg.inputs.input_image = 
#apply_rigid_reg.inputs.reference_image =
#apply_rigid_reg.inputs.output_image = 
#apply_rigid_reg.inputs.interpolation =
#apply_rigid_reg.inputs.default_value =
#apply_rigid_reg.inputs.transforms =
#apply_rigid_reg.inputs.invert_transform_flags = [False,False]

#apply_rigid = Node(apply_rigid_reg, name = 'apply_rigid')
#apply_rigid_reg.inputs.cmdline


# In[4]:

# Establish input/output stream

infosource = Node(IdentityInterface(fields=['subject_id']), name = "infosource")
infosource.iterables = [('subject_id', subject_list)]

lhtemplate_files = opj(datadir,'lhtemplate[0, 1, 2].nii.gz')
#label_files = opj(datadir,'{subject_id}-lab.nii.gz')
#t1_files = opj(datadir,'{subject_id}-t1-mask.nii.gz')
#t2_files = opj(datadir,'{subject_id}-t2s-bfc-mask.nii.gz')
mi_files = opj(datadir,"{subject_id}-*.nii.gz")
#mi_files.format(img_modality=('lab','t1-mask','t2s-bfc-mask'))
#rigid_reg_mat_files = opj('/spin1/users/zhoud4/ants_scripts/lh{subject_id}-30-pass1-0GenericAffine.mat')

templates = {'lhtemplate': lhtemplate_files,
            'mi': mi_files,
#            'rigid_mat': rigid_reg_mat_files,}
#            'label':label_files,
#            't1':t1_files,
#            't2':t2_files,
            }
selectfiles = Node(SelectFiles(templates, force_lists=['lhtemplate','mi'], 
                               sort_filelist = True, 
                               base_directory=datadir), 
                               name = "selectfiles")
#selectfiles.inputs.run = [{'lab','t1-mask','t2s-bfc-mask'}]

datasink = Node(DataSink(base_directory= datadir, container = 'output_dir'), name = "datasink")

substitutions = [('_subject_id_',''),
                ]


# In[5]:

# Create pipeline and connect nodes
workflow = Workflow(name='normflow')
workflow.base_dir = datadir
#workflow.add_nodes([test_antsreg_rigid])
workflow.connect([
                (infosource, selectfiles, [('subject_id', 'subject_id')]),
                (selectfiles, antsreg_rigid, [('lhtemplate','fixed_image'),('mi','moving_image')]),
#                  [(antsreg_rigid, apply_rigid), 
#                  ('rigid_mat','transforms'),('mi','input_image'),
#                   ('lhtemplate','reference_image')]
#                (antsreg_rigid, datasink, [('warped_image', 'antsreg.@warped_image'),
#                                           ('composite_transform','antsreg.@transform')])
                 ])

workflow.write_graph()
workflow.run(plugin='SLURM')
#workflow.run()


# In[ ]:



