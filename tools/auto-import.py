'''
Author: 15x3
Date: 2024-07-27 16:59:01
LastEditors: 15x3
LastEditTime: 2024-07-27 17:08:58
FilePath: \KennysFPSStarterPack\tools\auto-import.py
Description: 

Copyright (c) 2024 by 15x3, All Rights Reserved. 
'''
import bpy
import os

# 设置输出目录
output_dir = "D:\GodotProjects\2.Godot 4.0 Projects\KennysFPSStarterPack\models\Space-station-kit-imported"
suffix = "-col"  # 要添加的后缀名

# 确保输出目录存在
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# 获取所有对象
objects = bpy.context.scene.objects

# 遍历所有对象
for obj in objects:
    if obj.type == 'MESH':  # 只处理网格对象
        # 重命名对象，添加后缀
        original_name = obj.name
        new_name = original_name + suffix
        obj.name = new_name
        
        # 导出单个对象为 glTF 文件
        export_path = os.path.join(output_dir, new_name + ".glb")
        bpy.ops.export_scene.gltf(filepath=export_path, export_format='GLB', use_selection=True)

        # 恢复对象原名
        obj.name = original_name
