
# coding: utf-8

# In[23]:

# Import modules and set experiment-specific parameters
import copy
import os
import numpy as np
from os.path import join as opj
from nipype.pipeline.engine import Workflow, Node, MapNode, JoinNode
from nipype.interfaces.io import SelectFiles, DataSink
from nipype.interfaces.utility import IdentityInterface, Merge, Select
from nipype.interfaces.ants import Registration, ApplyTransforms, AverageImages
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

# Rigid Reg node 1

antsreg = Registration()
antsreg.inputs.float = True
antsreg.inputs.collapse_output_transforms=True
antsreg.inputs.output_transform_prefix = 'rigid_'
antsreg.inputs.fixed_image=[]
antsreg.inputs.moving_image=[]
antsreg.inputs.initial_moving_transform_com=1
antsreg.inputs.output_warped_image= True
antsreg.inputs.transforms=['Rigid']
antsreg.inputs.terminal_output='file'
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

antsreg_rigid = Node(antsreg,name='test_antsreg_rigid')
#antsreg.cmdline

# Apply Rigid Reg node 1

apply_rigid_reg = ApplyTransforms()

apply_rigid = MapNode(apply_rigid_reg, 
                      name = 'apply_rigid', 
                      iterfield=['input_image','reference_image','transforms'], 
                      nested = True
                     )
apply_rigid.inputs.input_image = []
apply_rigid.inputs.reference_image = []
apply_rigid.inputs.transforms = []
apply_rigid.inputs.terminal_output = 'file'
#apply_rigid_reg.cmdline


# In[64]:

# Select outputs by image type

    #Generate index lists
        # note, extended slices don't seem to work; e.g. [::3]

    #l = list(range(102))[::3]
    #l2 = [x+1 for x in l]
    #l3 = [x+2 for x in l2]

sl = Select()
sl = Node(sl, name = 'sl')
sl.inputs.inlist= []
sl.inputs.index=[0]

# Merge selected files into list

ml = Merge(1)
ml = JoinNode(ml, 
              name = 'ml',
             joinsource = 'infosource',
             joinfield = 'in1')
ml.inputs.in1 = []
ml.inputs.axis = 'hstack'
ml.inputs.no_flatten = True

# Average rigid-transformed images to construct new template

# TO DO: make this an iterable node

avg_rigid = AverageImages()
avg_rigid = Node(avg_rigid, 
                     name = 'avg_rigid',
                    joinsource = 'selectfiles',
                    joinfield = 'images')
avg_rigid.inputs.dimension = 3
avg_rigid.inputs.images = []
avg_rigid.inputs.normalize = True
avg_rigid.inputs.terminal_output = 'file'

#avg_rigid.cmdline


# In[25]:

# Establish input/output stream

#create subject ID iterable
infosource = Node(IdentityInterface(fields=['subject_id']), name = "infosource")
infosource.iterables = [('subject_id', subject_list)]

#create template
lhtemplate_files = opj(datadir,'lhtemplate[0, 1, 2].nii.gz')
mi_files = opj(datadir,'{subject_id}-*.nii.gz')

templates = {'lhtemplate': lhtemplate_files,
            'mi': mi_files,
            }

#select images organized by subject
selectfiles = Node(SelectFiles(templates, force_lists=['lhtemplate','mi'], 
                               sort_filelist = True, 
                               base_directory=datadir), 
                               name = "selectfiles")


#datasink = Node(DataSink(base_directory= datadir, container = 'output_dir'), name = "datasink")
#substitutions = [('_subject_id_',''),
#                ]


# In[65]:

#Define function to replicate fwd transforms to match iterfield length
def reptrans(forward_transforms):
    import numpy as np
    nested_list = np.ndarray.tolist(np.tile(forward_transforms,[1,3]))
    transforms = [val for sublist in nested_list for val in sublist]
    return transforms

#Define function to collapse nested list
def collapseList(nestedlist):
    return [item for elem in nestedlist for item in elem]

# Create pipeline and connect nodes
workflow = Workflow(name='normflow')
workflow.base_dir = datadir

#workflow.add_nodes([test_antsreg_rigid])
workflow.connect([
                (infosource, selectfiles, [('subject_id', 'subject_id')]),
                (selectfiles, antsreg_rigid, [('lhtemplate','fixed_image'),('mi','moving_image')]),
                (selectfiles, apply_rigid, [('lhtemplate','reference_image'),('mi','input_image')]),
                (antsreg_rigid, apply_rigid, [(('forward_transforms',reptrans),'transforms')]),
                (apply_rigid, sl, [('output_image', 'inlist')]),
                (sl, ml, [('out','in1')]),
#                (sl, ml, [('out','in1')]),
#                (apply_rigid, avg_rigid, [('output_image','images')]),
                 ])

#visualize workflow; makes graph with everything and simplified one
import pydotplus
#this module isn't included in default dependencies when installing nipype, bc the default only uses pydot
workflow.write_graph(graph2use='exec',format='png')
workflow.write_graph(graph2use='colored',format='png')
workflow.run(plugin='SLURM', plugin_args={'jobid_re': '([0-9]*)', 'sbatch_args': '-t 4 -g 4 --partition nimh'})
#workflow.run()


# In[40]:

# Scratch pad

import numpy as np
a = [1,2,3]
a = np.ndarray.tolist(np.tile(a,[1,3]))
flattened = [val for sublist in a for val in sublist]
print(flattened)

l = list(range(102))[::3]
l2 = [x+1 for x in l]
l3 = [x+2 for x in l2]
print(l2)
print(l3)

l4 = list(range(29))
print(l4)

