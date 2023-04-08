function write_color(color::Color, samples_per_pixel::Int32)
    r = color.x / Float64(samples_per_pixel)
    g = color.y / Float64(samples_per_pixel)
    b = color.z / Float64(samples_per_pixel)

    # Divide color by number of samples
    # scale = 1.0 / samples_per_pixel
    # r *= scale
    # g *= scale
    # b *= scale

    print(trunc(Int, 256 * clamp(sqrt(r), 0.0, 0.999)), " ", 
          trunc(Int, 256 * clamp(sqrt(g), 0.0, 0.999)), " ", 
          trunc(Int, 256 * clamp(sqrt(b), 0.0, 0.999)), "\n")
end
