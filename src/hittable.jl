mutable struct HitRecord
    p::Point3
    normal::Vec3
    mat::Material
    t::Float64
    front_face::Bool
end

function HitRecord()
    return HitRecord(Point3(0, 0, 0), Vec3(0, 0, 0), Lambertian(Color(1,1,1)), 0., false)
end

abstract type Hittable end

struct Sphere <: Hittable
    center::Point3
    radius::Float64
    mat::Material
end

function hit(obj::Sphere, r::Ray, t_min::Float64, t_max::Float64, rec::HitRecord)
    oc = r.origin - obj.center
    a = norm_squared(r.direction)
    half_b = dot(oc, r.direction)
    c = norm_squared(oc) - obj.radius^2
    discriminant = half_b^2 - a*c

    if (discriminant < 0)
        return false
    end

    sqrtd = sqrt(discriminant)

    # Find the nearest root in the acceptable range
    root = (-half_b - sqrtd) / a
    if root < t_min || t_max < root
        root = (-half_b + sqrtd) / a
        if root < t_min || t_max < root
            return false
        end
    end

    rec.t = root
    rec.p = at(r, rec.t)

    outward_normal = (rec.p - obj.center) / obj.radius
    rec.front_face = dot(r.direction, outward_normal) < 0
    rec.normal = rec.front_face ? outward_normal : -outward_normal;
    rec.mat = obj.mat
    return true
end

function hit(objects, r::Ray, t_min::Float64, t_max::Float64, rec::HitRecord)
    temp_rec = HitRecord()
    hit_anything = false
    closest_so_far = t_max

    for object in objects
        if hit(object, r, t_min, closest_so_far, temp_rec)
            hit_anything = true
            closest_so_far = temp_rec.t
            rec.p = temp_rec.p
            rec.normal = temp_rec.normal
            rec.mat = temp_rec.mat
            rec.t = temp_rec.t
            rec.front_face = temp_rec.front_face
        end
    end

    return hit_anything
end
