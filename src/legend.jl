function add_entry!(names, values, entry; default)
    i = findfirst(==(entry), names)
    if isnothing(i)
        push!(names, entry)
        push!(values, default)
        i = lastindex(names)
    end
    return values[i]
end

struct LegendSection
    title::String
    names::Vector{String}
    plots::Vector{Vector{AbstractPlot}}
end
LegendSection(title::String="") = LegendSection(title, String[], Vector{AbstractPlot}[])

# Add an empty trace list with name `entry` to the legend section
function add_entry!(legendsection::LegendSection, entry::String)
    names, plots = legendsection.names, legendsection.plots
    return add_entry!(names, plots, entry; default=AbstractPlot[])
end

struct Legend
    names::Vector{String}
    sections::Vector{LegendSection}
end
Legend() = Legend(String[], LegendSection[])

# Add an empty section with name `entry` and title `title` to the legend
function add_entry!(legend::Legend, entry::String; title::String="")
    names, sections = legend.names, legend.sections
    return add_entry!(names, sections, entry; default=LegendSection(title))
end

function create_legend(scene, legend::Legend)
    legend = remove_duplicates(legend)
    sections = legend.sections
    MakieLayout.LLegend(
        scene,
        getproperty.(sections, :plots),
        getproperty.(sections, :names),
        getproperty.(sections, :title)
    )
end

function remove_duplicates(legend)
    sections = legend.sections
    
    # check if there are duplicates
    titles = getproperty.(sections, :title)
    unique_titles = unique(titles)
    has_duplicates = length(unique_titles) < length(titles)
    
    # if there are duplicates, create new legend without duplicates
    if has_duplicates
        @show "has duplicate sections"
        unique_sections = map(unique_titles) do title
            unique_inds = titles .== title
            dup_sections          = sections[unique_inds]
            names_of_dup_sections = legend.names[unique_inds]
        
            names_vec = reduce(vcat, getproperty.(dup_sections, :names))
            plots_vec = reduce(vcat, getproperty.(dup_sections, :plots))
        
            names_new = []
            plots_new = []
        
            for (name, plots) in zip(names_vec, plots_vec)
                i = findfirst(name .== names_new)
                isnew = isnothing(i)
                    
                if isnew
                    push!(names_new, name)
                    push!(plots_new, plots)
                else
                    plots_new[i] = union(plots_new[i], plots)
                end
            end    
              
            section = AlgebraOfGraphics.LegendSection(title, names_new, plots_new)
            name = prod(names_of_dup_sections)
              
            (; section, name)
              
        end |> StructArray
        @show unique_sections.name
        return Legend(unique_sections.name, unique_sections.section)
    else
        return legend
    end
end

