mutable struct Camera
    origin
    horizontal
    vertical
    lower_left_corner
    u
    v
    w
    lens_radius
end

# function Camera()
#     aspect_ratio = 16. / 9.
#     viewport_height = 2.0
#     viewport_width = aspect_ratio * viewport_height
#     focal_length = 1.0

#     origin = Point3(0, 0, 0)
#     horizontal = Vec3(viewport_width, 0, 0)
#     vertical = Vec3(0, viewport_height, 0)
#     lower_left_corner = origin - horizontal/2 - vertical/2 - Vec3(0, 0, focal_length)

#     return Camera(origin, horizontal, vertical, lower_left_corner) 
# end

# function Camera(vfov, aspect_ratio)
#     theta = deg2rad(vfov)
#     h = tan(theta/2)
#     viewport_height = 2.0 * h
#     viewport_width = aspect_ratio * viewport_height
# 
#     focal_length = 1.0
# 
#     origin = Point3(0, 0, 0)
#     horizontal = Vec3(viewport_width, 0, 0)
#     vertical = Vec3(0, viewport_height, 0)
#     lower_left_corner = origin - horizontal/2 - vertical/2 - Vec3(0, 0, focal_length)
# 
#     return Camera(origin, horizontal, vertical, lower_left_corner) 
# end

function Camera(look_from, look_at, vup, vfov, aspect_ratio, aperture, focus_dist)
    theta = deg2rad(vfov)
    h = tan(theta/2)
    viewport_height = 2.0 * h
    viewport_width = aspect_ratio * viewport_height

    w = unit_vector(look_from - look_at)
    u = unit_vector(cross(vup, w))
    v = cross(w, u)

    origin = look_from
    horizontal = focus_dist * viewport_width * u
    vertical = focus_dist * viewport_height * v
    lower_left_corner = origin - horizontal/2 - vertical/2 - focus_dist*w
    lens_radius = aperture/2

    return Camera(origin, horizontal, vertical, lower_left_corner, u, v, w, lens_radius) 
end

function get_ray(cam::Camera, s, t)
    rd = cam.lens_radius * random_vec3_in_unit_disk()
    offset = cam.u * rd.x + cam.v * rd.y
    return Ray(cam.origin + offset, cam.lower_left_corner + s*cam.horizontal + t*cam.vertical - cam.origin - offset)
end