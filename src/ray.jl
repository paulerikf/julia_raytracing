struct Ray
    origin::Point3
    direction::Vec3
end

function Ray()
    return Ray(Point3(0, 0, 0), Vec3(0, 0, 0))
end

function at(r::Ray, t::Float64)
    return r.origin + t*r.direction
end