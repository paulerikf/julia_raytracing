function hit_sphere(center::Point3, radius::Float64, r::Ray)
    oc = r.origin - center
    a = norm_squared(r.direction)
    half_b = dot(oc, r.direction)
    c = norm_squared(oc) - radius^2
    discriminant = half_b^2 - a*c

    if (discriminant < 0)
        return -1.0;
    else
        return (-half_b - sqrt(discriminant)) / a
    end
end

function ray_color(r::Ray, world, depth)
    rec = HitRecord()

    if depth <= 0
        return Color(0,0,0)
    end

    if hit(world, r, 0.001, Inf, rec)
        ray_state = RayState(Color(0., 0., 0.), Ray())
        if scatter(rec.mat, r, rec, ray_state)
            # print(stderr, "Ray state: ", ray_state.attenuation, "\n")
            # print(stderr, "Mat: ", rec.mat, "\n")
            return ray_state.attenuation.*ray_color(ray_state.scattered, world, depth-1)
        end
        return Color(0., 0., 0.)
    end

    # Else sky gradient
    unit_direction = unit_vector(r.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    return (1.0-t) * Color(1, 1, 1) + t * Color(0.5, 0.7, 1.0)
end

function random_scene()
    world = []

    ground_material = Lambertian(Color(0.5, 0.5, 0.5))
    push!(world, Sphere(Point3(0, -1000, 0), 1000, ground_material))

    for a in [-11:11;]
        for b in [-11:11;]
            choose_mat = rand()
            center = Point3(a + 0.9*rand(), 0.2, b + 0.9*rand())

            if choose_mat < 0.8
                # diffuse
                albedo = random_vec3().*random_vec3()
                sphere_material = Lambertian(albedo)
            elseif choose_mat < 0.95
                # Metal
                albedo = random_vec3(0.5, 1.)
                fuzz = rand(0:eps():0.5)
                sphere_material = Metal(albedo, fuzz)
            else
                # Glass
                sphere_material = Dielectric(1.5)
            end
            push!(world, Sphere(center, 0.2, sphere_material))
        end
    end

    push!(world, Sphere(Point3( 0,1,0), 1.0, Dielectric(1.5)))
    push!(world, Sphere(Point3(-4,1,0), 1.0, Lambertian(Color(0.4, 0.2, 0.1))))
    push!(world, Sphere(Point3( 4,1,0), 1.0, Metal(Color(0.7, 0.6, 0.5), 0.0)))

    return world
end

function do_render()
    # Image
    aspect_ratio = 3.0 / 2.0
    image_width = 1200
    image_height = trunc(Int, image_width / aspect_ratio)
    samples_per_pixel = Int32(500)
    max_depth = 50

    # World
    world = random_scene()
    print(stderr, world)

    # Camera
    look_from = Point3(13, 2, 3)
    look_at = Point3(0, 0, 0)
    dist_to_focus = 10.0 # norm(look_from-look_at)
    aperture = 0.1

    cam = Camera(look_from, look_at, Vec3(0,1,0), 20.0, aspect_ratio, aperture, dist_to_focus)

    print(stderr, "Mat: ", world[1].mat, "\n")
    # Render
    print("P3\n" * string(image_width) * " " * string(image_height) * "\n255\n")

    for j in [image_height:-1:1;]
        print(stderr, "\rScanlines remaining: ", j, " ", flush)
        for i in [1:image_width;]
            pixel_color = Color(0,0,0)
            for s in [1:samples_per_pixel;]
                u = (Float64(i) + rand()) / (image_width - 1)
                v = (Float64(j) + rand()) / (image_height - 1)
                r = get_ray(cam, u, v)
                pixel_color += ray_color(r, world, max_depth)
            end
            write_color(pixel_color, samples_per_pixel)
        end
    end
    print(stderr, "\nDone")
end
