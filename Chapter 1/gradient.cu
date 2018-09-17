#include <fstream>
#include <iostream>
#include <string>

const int ImageWidth = 1024;
const int ImageHeight = 512;

struct PixelColor
{
    float r;
    float g;
    float b;
};

// Kernel function to add the elements of two arrays
__global__
void CalculatePixelColors(int width, int height, PixelColor* pixels)
{
    int k = 0;
    for (int j = height - 1; j >= 0; --j)
    {
        for (int i = 0; i < width; ++i)
        {
            pixels[k].r = static_cast<float>(i) / static_cast<float>(width);
            pixels[k].g = static_cast<float>(j) / static_cast<float>(height);
            pixels[k].b = 0.2;
            k++;
        }
    }
}

void SaveImage(std::string fileName, int width, int height, PixelColor* pixels)
{
  std::ofstream imageFile;
  imageFile.open(fileName.c_str());
  imageFile << "P3" << std::endl  << width << " " << height << std::endl << 255 << std::endl;
  int k = 0;
  for (int j = 0; j < height; ++j)
  {
      for (int i = 0; i < width; ++i)
      {
          int ir = static_cast<int>(255.99 * pixels[k].r);
          int ig = static_cast<int>(255.99 * pixels[k].g);
          int ib = static_cast<int>(255.99 * pixels[k].b);
          imageFile << ir << " " << ig << " " << ib << std::endl;
          k++;
      }
  }
  imageFile.close();
}

int main(int argc, char** argv)
{
  // Get image file name
  std::string fileName = "gradient.ppm";
  if (argc > 1)
  {
      fileName = argv[1];
  }

  // Allocate Unified Memory – accessible from CPU or GPU
  int numPixels = ImageWidth*ImageHeight;
  PixelColor *pixels;
  cudaMallocManaged(&pixels, numPixels*sizeof(PixelColor));

  // Run kernel on 1M elements on the GPU
  CalculatePixelColors<<<1, 1>>>(ImageWidth, ImageHeight, pixels);

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();

  SaveImage(fileName, ImageWidth, ImageHeight, pixels);

  // Free memory
  cudaFree(pixels);
  
  return 0;
}