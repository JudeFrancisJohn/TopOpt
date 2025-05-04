#This function receives as input 4 planar nodal coordinates
# and then invokes the Gmsh API for meshing in Julia

using Gmsh: gmsh, gmsh

function create_quad_mesh(points::Vector{Tuple{Float64, Float64}}, mesh_size::Float64)
    if length(points) != 4
        error("Exactly four points must be provided.")
    end

    
    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 1)
    gmsh.model.add("quadModel")

    
    #points = ((0,0),(1,0),(1,1),(0,1))
    for (i, (x, y))  in enumerate(points)
        gmsh.model.geo.addPoint(x, y, 0, mesh_size, i)
        #println("x:  ",x,"  y:  ",y)
    end

    # Add lines
    gmsh.model.geo.addLine(1, 2, 1)
    gmsh.model.geo.addLine(2, 3, 2)
    gmsh.model.geo.addLine(3, 4, 3)
    gmsh.model.geo.addLine(4, 1, 4)

    # Curve loop and surface
    gmsh.model.geo.addCurveLoop([1, 2, 3, 4], 1)
    gmsh.model.geo.addPlaneSurface([1], 1)


    # Force quadrilateral mesh
    gmsh.model.geo.synchronize()
    gmsh.model.mesh.setRecombine(2, 1)  # Recombine surface 1 into quads

    # Choose a quadrilateral mesh algorithm
    # 1 = MeshAdapt, 5 = Delaunay, 6 = Frontal, 7 = BAMG, 8 = Frontal-Delaunay, 9 = Packing of Parallelograms
    gmsh.option.setNumber("Mesh.Algorithm", 5)  # Delaunay for quads

    # Mesh generation
    gmsh.model.mesh.generate(2)

    # Save as VTK
    gmsh.write("quad_mesh.vtk")

    # Extract node coordinates
    node_tags, node_coords, _ = gmsh.model.mesh.getNodes()
    coords_matrix = reshape(node_coords, 3, length(node_tags))
    sorted_indices = sortperm(node_tags)
    sorted_coords = coords_matrix[:, sorted_indices]
    xy_coords = transpose(sorted_coords[1:2, :])  # Nx2

    
    # Map: node_tag => index in matrix
    node_tag_to_index = Dict(tag => i for (i, tag) in enumerate(node_tags[sorted_indices]))

    # Get element connectivity for quadrangles (type 3)
    elem_types, elem_tags, elem_node_tags = gmsh.model.mesh.getElements(2)
    quad_index = findfirst(==(3), elem_types)  # type 3 = 4-node quad

    if quad_index === nothing
        error("No quadrilateral elements found.")
    end

    quads = elem_node_tags[quad_index]
    num_quads = length(quads) ÷ 4
    connectivity = reshape(quads, 4, num_quads)'  # Mx4
    #gmsh.fltk.run()
    
    gmsh.finalize()

    return xy_coords, connectivity
end


