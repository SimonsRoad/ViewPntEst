import math
import bpy
import sys
import numpy as np
from subprocess import call
#argv = sys.argv[sys.argv.index("--") + 1:]
#i = int(argv[0])

pi = math.pi;
def rand(l, h):
    return np.random.uniform(l,h)

N_FRAME = 150
N_REPS = 500

results = np.zeros((2 * N_REPS, 3 * N_FRAME + 1))
bounce = [0, 0.7]
for b in range(len(bounce)):
    for r in range(N_REPS):
        bpy.data.objects["Cube"].rigid_body.restitution = bounce[b]
        bpy.data.objects["Plane"].rigid_body.restitution = bounce[b]


        bpy.context.scene.frame_set(1)
        bpy.data.objects["Cube"].location.xyz=[0,0, rand(2,3)]
        bpy.data.objects["Cube"].keyframe_insert(data_path="location")
    
        bpy.context.scene.frame_set(7)
        bpy.data.objects["Cube"].location.xyz=[rand(-3,3), rand(-3,3), rand(2,3)]
        bpy.data.objects["Cube"].rotation_euler=[rand(-pi,pi), rand(-pi,pi), rand(-pi,pi)]
        bpy.data.objects["Cube"].keyframe_insert(data_path="location")

        coords = []
        for i in range(1,N_FRAME + 7):
            bpy.context.scene.frame_set(i)
            if i>=7:
                coords.append(list(bpy.data.objects["Cube"].matrix_world.translation))

        results[b * N_REPS + r, 0] = b
        results[b * N_REPS + r, 1:] = [x for sublist in list(map(list, zip(*coords))) for x in sublist]

np.savetxt('./blender/blender_TRAIN.txt',results, delimiter=',')


#####################
print('create test data....')
results = np.zeros((2 * N_REPS, 3 * N_FRAME + 1))
for b in range(len(bounce)):
    for r in range(N_REPS):
        bpy.data.objects["Cube"].rigid_body.restitution = bounce[b]
        bpy.data.objects["Plane"].rigid_body.restitution = bounce[b]


        bpy.context.scene.frame_set(1)
        bpy.data.objects["Cube"].location.xyz=[0,0, rand(2,3)]
        bpy.data.objects["Cube"].keyframe_insert(data_path="location")
    
        bpy.context.scene.frame_set(7)
        bpy.data.objects["Cube"].location.xyz=[rand(-3,3), rand(-3,3), rand(2,3)]
        bpy.data.objects["Cube"].rotation_euler=[rand(-pi,pi), rand(-pi,pi), rand(-pi,pi)]
        bpy.data.objects["Cube"].keyframe_insert(data_path="location")

        coords = []
        for i in range(1,N_FRAME + 7):
            bpy.context.scene.frame_set(i)
            if i>=7:
                coords.append(list(bpy.data.objects["Cube"].matrix_world.translation))

        results[b * N_REPS + r, 0] = b
        results[b * N_REPS + r, 1:] = [x for sublist in list(map(list, zip(*coords))) for x in sublist]

np.savetxt('./blender/blender_TEST.txt',results, delimiter=',')



