using StaticArrays

struct Vec3 <: FieldVector{3, Float64}
    x::Float64
    y::Float64
    z::Float64
end

Point3 = Vec3
Color = Vec3

function norm(vec::Vec3)
    return sqrt(norm_squared(vec))
end

function norm_squared(vec::Vec3)
    return vec.x^2 + vec.y^2 + vec.z^2
end

function unit_vector(vec::Vec3)
    return vec / norm(vec)
end

function dot(u::Vec3, v::Vec3)
    return u.x * v.x + u.y * v.y + u.z * v.z
end

function cross(u::Vec3, v::Vec3)
    return Vec3(u.y * v.z - u.z * v.y,
                u.z * v.x - u.x * v.z,
                u.x * v.y - u.y * v.x)
end

function random_vec3()
    return Vec3(rand(), rand(), rand())
end

function random_vec3(min::Float64, max::Float64)
    return (max-min) * random_vec3() + Vec3(min, min, min)
end

function random_vec3_in_unit_sphere()
    while (true)
        p = random_vec3(-1.0, 1.0)
        if norm_squared(p) >= 1
            continue
        end
        return p
    end
end

function random_unit_vector()
    return unit_vector(random_vec3_in_unit_sphere())
end

function random_vec3_in_hemisphere(normal::Vec3)
    in_unit_sphere = random_vec3_in_unit_sphere()
    if dot(in_unit_sphere, normal) > 0.0  # In the same hemisphere as normal
        return in_unit_sphere
    else
        return -in_unit_sphere
    end
end

function near_zero(v::Vec3)
    s = 1e-8
    return abs(v.x) < s && abs(v.y) < s && abs(v.z) < s
end

function reflect(v::Vec3, n::Vec3)
    return v - 2*dot(v, n)*n
end

function refract(uv::Vec3, n::Vec3, etai_over_etat::Float64)
    cos_θ = min(dot(-uv, n), 1.0)
    r_out_perp = etai_over_etat * (uv + cos_θ*n)
    r_out_parallel = -sqrt(abs(1.0 - norm_squared(r_out_perp))) * n
    return r_out_perp + r_out_parallel
end

function random_vec3_in_unit_disk()
    while true
        p = Vec3(rand(-1:eps():1), rand(-1:eps():1), 0.)
        if norm_squared(p) >= 1
            continue
        end
        return p
    end
end
