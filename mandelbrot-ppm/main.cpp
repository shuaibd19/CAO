#include <iostream>
#include <fstream>
#include <math.h>

#define M_PI 3.14159265358979323846  /* pi */
#define M_EUL 2.71828182845904523536  /*eulers number*/
using namespace std;

float mapToReal(int x, int width, float minReal, float maxReal);
float mapToImag(int y, int height, float minIm, float maxIm);
int mandelbrot(float cR, float cI, int maxIterations);

int main()
{
	const int width = 600;
	const int height = 600;

	const float ReMIN = -2.5;
	const float ReMAX = 0.7;
	const float ImMIN = -2.0;
	const float ImMAX = 2.0;
	const float maxIT = 255;

	

	/*PPM file format
	the first line is reserved for the header which in this case is going
	to be P3 this means that it will be in the format of RGB in ASCII.
	The next two values will be the image width and height which will be as
	defined above. And the last bit of information the file needs is the 
	maximum value for each colour which in RGB is 255*/




	/*logical basis for the algorithm: (as taken from wikipedia)

	while(x*x + y*y < 2*2 AND iteration < max_iteration)
		{
			xtemp = x*x - y*y +x0;
			y = 2*x*y + y0;
			x = xtemp;
			iteration++;
		}*/



	ofstream mandImg("madelbrot.ppm");
	if (mandImg.is_open())
	{
		mandImg << "P3\n" << width << " " << height << " 256\n"; //max rbg pixel value is 256
		for (int y = 0; y < height; y++) // rows
		{
			for (int x = 0; x < width; x++) // pixel in that row
			{
				/*for every pixel find the real and imaginary values for c, 
				which corresponds to the x, y coordinate pixel in image*/
				float cReal = mapToReal(x, width, ReMIN, ReMAX);
				float cImag = mapToImag(y, height, ImMIN, ImMAX);

				//find the the number of iterations it took using c
				int n = mandelbrot(cReal, cImag, maxIT);

				//map to a arbitrary rgb value
				int r = ((int)(n * sinf(M_PI)) % 256);
				int g = ((int)(pow(n, M_EUL)) % 256);
				int b = (n % 256);

				//map to the ppm file
				mandImg << r << " " << g << " " << b << " ";
			}
			mandImg << endl;
		}

		mandImg.close();
	}
	else
	{
		cout << "ERROR: Could not open file\n";
	}

	return 0;
}


float mapToReal(int x, int width, float minReal, float maxReal)
{
	float range = maxReal - minReal;
	return x * (range / width) + minReal;
}

float mapToImag(int y, int height, float minIm, float maxIm)
{
	float range = minIm - maxIm;
	return y * (range / height) + maxIm;
}

int mandelbrot(float cR, float cI, int maxIterations)
{
	int i = 0;
	float zR = 0.0f, zI = 0.0f;
	while (i < maxIterations && zR*zR + zI*zI < 2.0*2.0)
	{
		float temp = zR * zR - zI * zI + cR;
		zI = 2.0f * zR * zI + cI;
		zR = temp;
		i++;
	}

	return i;
}
