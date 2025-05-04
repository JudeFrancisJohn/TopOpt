#main file

#==== Test : Meshing =============#

# Define the input points as a Vector of Tuples
points = [(0.0, 0.0), (3.0, 0.0), (1.0, 2.5), (0.0, 1.0)]

# Define the mesh size
mesh_size = 0.125

# Call the function
xy_coords, connectivity = create_quad_mesh(points, mesh_size)

# Print the output (coordinates and connectivity)
println("Node coordinates:")
println(size(xy_coords))

println("\nElement connectivity:")
println(size(connectivity))
