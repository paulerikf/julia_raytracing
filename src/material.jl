abstract type Material end

struct Lambertian <: Material
    albedo::Color
end

struct Metal <: Material
    albedo::Color
    fuzz::Float64
end

struct Dielectric <: Material
    ir::Float64
end

mutable struct RayState
    attenuation::Color
    scattered::Ray
end

function scatter(mat::Lambertian, r_in::Ray, rec, state::RayState)
    scatter_dir = rec.normal + random_unit_vector()

    if near_zero(scatter_dir)
        scatter_dir = rec.normal
    end

    state.scattered = Ray(rec.p, scatter_dir)
    state.attenuation = mat.albedo
    return true
end

function scatter(mat::Metal, r_in::Ray, rec, state::RayState)
    reflected = reflect(unit_vector(r_in.direction), rec.normal)
    state.scattered = Ray(rec.p, reflected + mat.fuzz*random_vec3_in_unit_sphere())
    state.attenuation = mat.albedo
    return dot(state.scattered.direction, rec.normal) > 0
end
    
function reflectance(cosine::Float64, ref_idx::Float64)
    r0 = (1-ref_idx) / (1+ref_idx)
    r0 = r0*r0
    return r0 + (1-r0)*(1-cosine)^5
end

function scatter(mat::Dielectric, r_in::Ray, rec, state::RayState)
    refraction_ratio = rec.front_face ? (1.0/mat.ir) : mat.ir

    unit_direction = unit_vector(r_in.direction)
    cos_θ = min(dot(-unit_direction, rec.normal), 1.0)
    sin_θ = sqrt(1.0 - cos_θ^2)

    cannot_refract = refraction_ratio * sin_θ > 1.0

    if cannot_refract || reflectance(cos_θ, refraction_ratio) > rand()
        direction = reflect(unit_direction, rec.normal)
    else
        direction = refract(unit_direction, rec.normal, refraction_ratio)
    end

    state.attenuation = Color(1.0, 1.0, 1.0)
    state.scattered = Ray(rec.p, direction)
    return true
end