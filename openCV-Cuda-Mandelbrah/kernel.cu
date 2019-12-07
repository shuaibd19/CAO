//
//#include "cuda_runtime.h"
//#include "device_launch_parameters.h"
//#include <cuda.h>
//#include <iostream>
//#include <math.h>
//#include <fstream>
//#include <windows.h> // contains windef.h which has all the bitmap stuff
//#include <stdio.h> // defines FILENAME_MAX
//#include <stdlib.h>
//#include <direct.h>
//#include <opencv2/opencv.hpp>
//#include <opencv2/imgproc/imgproc.hpp>
//#include <opencv2/highgui/highgui.hpp>
//#include <opencv2/core/core.hpp>
//
//using namespace cv;
//using namespace std;
//
//
//// dimensions are hard coded
//#define WIDTH 4096
//#define HEIGHT 4096
//
//
//// this kernel calculates the pixel value for one pixel
//__global__ void mandelbrot(BYTE* imageData, float unitX, float unitY, int max, int pixelWidth)
//{
//	// get the unique thread index
//	// only using 1, 1 grid
//	int row = blockIdx.y * blockDim.y + threadIdx.y;
//	int col = blockIdx.x * blockDim.x + threadIdx.x;
//
//	// offset values so center is 0, 0
//	float offsetWidth = col - (WIDTH / 2);
//	float offsetHeight = row - (HEIGHT / 2);
//
//	// multiply by our units (applies the zoom)
//	float translatedWidth = offsetWidth * unitX;
//	float translatedHeight = offsetHeight * unitY;
//
//	float x = 0, y = 0;
//	int iter = 0;
//
//	int pos = (WIDTH * row) + col; // the position in the pixel data byte array
//
//	// keep iterating until point escapes mandlebrot set
//	while (1)
//	{
//		if (sqrt((x*x) + (y*y)) > 2) // if magnitude is greater than 2
//		{
//			// point has escaped mandlebrot set - paint white
//			imageData[pos * pixelWidth] = (BYTE)255;
//			break;
//		}
//		if (iter == max)
//		{
//			// point is in the mandlebrot set - paint black
//			imageData[pos * pixelWidth] = (BYTE)0;
//			break;
//		}
//
//		// this applies the mandelbrot equation
//		// Zn+1 = Zn^2 + C
//		float temp = ((x*x) - (y*y)) + translatedWidth;
//		y = (2 * x*y) + translatedHeight;
//		x = temp;
//		iter++;
//	}
//}
//
//int main(int argc, char** argv[])
//{
//	printf("Building image data...\n");
//
//	// this is hard coded sadly
//	dim3 grid(256, 256);
//	dim3 block(16, 16);
//
//	int pixelWidth = 1; // in bytes. bmp doesn't really do binary images so 1 byte is minimum
//	int imageSize = WIDTH * HEIGHT * pixelWidth; // in bytes
//
//	// allocate device memory
//	BYTE * imageData_d = NULL;
//	cudaMalloc((void **)&imageData_d, imageSize);
//
//	// the interesting stuff in the mandlebrot set occurs between -2,-2 and 2,2
//	float zoomX = 2, zoomY = 2;
//
//	// max iterations
//	// increasing iterations improves image quality but hits performance
//	int max = 1000;
//
//	float unitX = zoomX / (WIDTH / 2);
//	float unitY = zoomY / (HEIGHT / 2);
//
//	// launch kernel on each pixel
//	mandelbrot <<<grid, block >>> (imageData_d, unitX, unitY, max, pixelWidth);
//
//	// copy data back to host
//	BYTE * imageData_h = (BYTE*)malloc(imageSize);
//	cudaMemcpy(imageData_h, imageData_d, imageSize, cudaMemcpyDeviceToHost);
//
//	// construct the bitmap info header (DIB header)
//	BITMAPINFOHEADER bmpInfoHeader = { 0 };
//	bmpInfoHeader.biSize = sizeof(BITMAPINFOHEADER); // should be 40 bytes
//	bmpInfoHeader.biHeight = HEIGHT;
//	bmpInfoHeader.biWidth = WIDTH;
//	bmpInfoHeader.biPlanes = 1; // number of color planes (always 1)
//	bmpInfoHeader.biBitCount = pixelWidth * 8;
//	bmpInfoHeader.biCompression = BI_RGB; // do not compress
//	bmpInfoHeader.biSizeImage = imageSize; // image size in bytes
//	bmpInfoHeader.biClrUsed = 0; // no colors
//	bmpInfoHeader.biClrImportant = 0; // all colors important
//
//	// construct bitmap file header
//	BITMAPFILEHEADER bfh;
//	bfh.bfType = 0x4D42; // the first two bytes of the file are 'BM' in ASCII, in little endian
//	bfh.bfOffBits = sizeof(BITMAPINFOHEADER) + sizeof(BITMAPFILEHEADER) + (sizeof(RGBQUAD) * 256); // the offset (starting address of pixel data). size of headers + color table
//	bfh.bfSize = bfh.bfOffBits + bmpInfoHeader.biSizeImage; // total size of image including size of headers
//
//	// create the color table
//	RGBQUAD colorTable[256];
//	for (int i = 0; i < 256; i++)
//	{
//		colorTable[i].rgbBlue = (BYTE)i;
//		colorTable[i].rgbGreen = (BYTE)i;
//		colorTable[i].rgbRed = (BYTE)i;
//		colorTable[i].rgbReserved = (BYTE)i;
//	}
//
//	// write everything to file
//	ofstream imageFile;
//
//	char filePath[FILENAME_MAX];
//	// get the current working directory
//	if (!_getcwd(filePath, FILENAME_MAX))
//	{
//		printf("error accessing current working directory\n");
//		return 0;
//	}
//
//	printf("The current working directory is %s\n", filePath);
//	strcat_s(filePath, "\\mandelbrot.bmp"); // append the image file name
//
//	imageFile.open(filePath);
//	imageFile.write((char *)&bfh, sizeof(bfh)); // Write the File header
//	imageFile.write((char *)&bmpInfoHeader, sizeof(bmpInfoHeader)); // Write the bitmap info header
//	imageFile.write((char *)&colorTable, sizeof(RGBQUAD) * 256); // Write the color table
//
//	// if number of rows is a multiple of 4 bytes
//	if (WIDTH % 4 == 0)
//	{
//		// write the image judata
//		imageFile.write((char*)imageData_h, bmpInfoHeader.biSizeImage);
//	}
//	else
//	{
//		// else write and pad each row out with empty bytes
//		char* padding = new char[4 - WIDTH % 4];
//		for (int i = 0; i < HEIGHT; ++i)
//		{
//			imageFile.write((char *)&imageData_h[i * WIDTH], WIDTH);
//			imageFile.write((char *)padding, 4 - WIDTH % 4);
//		}
//	}
//
//	imageFile.close();
//	printf("image file saved to %s\n", filePath);
//
//	// clean up
//	cudaDeviceReset();
//	cudaFree(imageData_d);
//	free(imageData_h);
//
//	Mat imgjay = imread("mandelbrot.bmp");
//	namedWindow("MandelBrot View", 0);
//	imshow("MandelBrot View", imgjay);
//
//	waitKey(0);
//
//	return 0;
//}


#include "fractal.hpp"
#include <iostream>
#include <cmath>
#include <cstring>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace std;
using namespace cv;

#ifdef __CUDACC__

__global__ static void calculateMandelbrot(char *imageBuffer, double cx0, double cy0, double cx1, double cy1,
	int width, int height, int maxIter);

#define cudaCheck(ins) { _cudaCheck(ins, __FILE__, __LINE__); }

inline void _cudaCheck(cudaError_t code, const char *file, int line)
{
	if (code != cudaSuccess)
	{
		fprintf(stderr, "cudaCheck: %s %s %d\n", cudaGetErrorString(code), file, line);
		exit(code);
	}
}

#else

static void calculateMandelbrotCPU(char *imageBuffer, double cx0, double cy0, double cx1, double cy1,
	int width, int height, int maxIter);

#endif

Fractal::Fractal(double cx0, double cy0, double cx1, double cy1, int width, int height, int maxIter)
{
	SetDimensions(cx0, cy1, cx1, cy1, maxIter);
	this->width = width;
	this->height = height;
	this->imageBuffer = new char[width * height * 3];
}

Fractal::~Fractal()
{
	delete[] this->imageBuffer;
}

void Fractal::SetDimensions(double cx0, double cy0, double cx1, double cy1, int maxIter)
{
	this->cx0 = cx0;
	this->cy0 = cy0;
	this->cx1 = cx1;
	this->cy1 = cy1;
	this->maxIter = maxIter;
}

char *Fractal::GetImageBuffer()
{

#ifdef __CUDACC__

	dim3 threadsPerBlock(16, 16);
	dim3 blocksPerGrid(this->width / threadsPerBlock.x, this->height / threadsPerBlock.y);

	char *imageBuffer_d;

	cudaCheck(cudaMalloc(&imageBuffer_d, width * height * 3));
	calculateMandelbrot << <blocksPerGrid, threadsPerBlock >> > (imageBuffer_d, this->cx0, this->cy0, this->cx1, this->cy1,
		this->width, this->height, this->maxIter);

	cudaCheck(cudaMemcpy(imageBuffer, imageBuffer_d, width * height * 3, cudaMemcpyDeviceToHost));
	cudaCheck(cudaFree(imageBuffer_d));

#else

	calculateMandelbrotCPU(this->imageBuffer, this->cx0, this->cy0, this->cx1, this->cy1,
		this->width, this->height, this->maxIter);

#endif

	return this->imageBuffer;
}

#ifdef __CUDACC__

__global__ static void calculateMandelbrot(char *imageBuffer, double cx0, double cy0, double cx1, double cy1,
	int width, int height, int maxIter)
{
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	int pixelId = (row * width + col) * 3;

	double x = 0, y = 0;
	double cx = (double)col / width * (cx1 - cx0) + cx0;
	double cy = (double)row / height * (cy0 - cy1) + cy1;

	int numberOfIterations = 0;
	double tempx;

	while ((x * x + y * y < 4.0) && (numberOfIterations <= maxIter))
	{
		tempx = x * x - y * y + cx;
		y = 2.0 * x * y + cy;
		x = tempx;
		numberOfIterations++;
	}

	int color = numberOfIterations;

	if (numberOfIterations == maxIter) color = 0;

	imageBuffer[pixelId] = 255 - color % 256;//color % 256;
	imageBuffer[pixelId + 1] = 0;
	imageBuffer[pixelId + 2] = color * 5 % 256;
}

#else

static void calculateMandelbrotCPU(char *imageBuffer, double cx0, double cy0, double cx1, double cy1,
	int width, int height, int maxIter)
{
	int nt, tid;
#pragma omp parallel private(tid)
	{
		nt = omp_get_num_threads();
		tid = omp_get_thread_num();
		int kt = (tid + 1) * (height / nt);
		int k = tid * (height / nt);
		//printf("nt: %d", nt);

		for (; k < kt; k++)
			for (int j = 0; j < width; j++)
			{
				int row = k;
				int col = j;
				int pixelId = (row * width + col) * 3;

				double x = 0, y = 0;
				double cx = (double)col / width * (cx1 - cx0) + cx0;
				double cy = (double)row / height * (cy0 - cy1) + cy1;

				int numberOfIterations = 0;
				double tempx;

				while ((x * x + y * y < 4.0) && (numberOfIterations <= maxIter))
				{
					tempx = x * x - y * y + cx;
					y = 2.0 * x * y + cy;
					x = tempx;
					numberOfIterations++;
				}

				int color = numberOfIterations;

				if (numberOfIterations == maxIter) color = 0;

				imageBuffer[pixelId] = 255 - color % 256;//color % 256;
				imageBuffer[pixelId + 1] = 0;
				imageBuffer[pixelId + 2] = color * 5 % 256;
			}
		//printf("thread %d finished\n", tid);
	}
}

#endif

int width = 1024, height = 1024, maxIter = 250;
double cx0 = -2, cy0 = -1.5, cx1 = 1, cy1 = 1.5, rangex, rangey;

Mat output(width, height, CV_8UC3);

bool clicked = false;
bool isImgCorrect = false;

double tempcx0, tempcy0, tempcx1, tempcy1;

void reset()
{
	cx0 = -2; cy0 = -1.5; cx1 = 1; cy1 = 1.5;
	maxIter = 250;
	isImgCorrect = false;
}

void mouseCallBack(int event, int x, int y, int flags, void *userdata);

int main(int argc, char *argv[])
{
	Fractal mandelbrot(cx0, cy0, cx1, cy1, width, height, maxIter);

	namedWindow("MandelWindow", 1);

	setMouseCallback("MandelWindow", mouseCallBack);

	for (;;)
	{
		if (!isImgCorrect)
		{
			mandelbrot.SetDimensions(cx0, cy0, cx1, cy1, maxIter);
			memcpy(output.data, mandelbrot.GetImageBuffer(), width * height * 3);

			imshow("MandelWindow", output);

			isImgCorrect = true;
		}
		int key = waitKey(5);

		switch (key)
		{
		case 'q':
			return 0;
		case 'k':
			rangey = cy1 - cy0;
			cy0 += ((double)1 / 5) * rangey;
			cy1 += ((double)1 / 5) * rangey;
			isImgCorrect = false;
			break;
		case 'j':
			rangey = cy1 - cy0;
			cy0 -= ((double)1 / 5) * rangey;
			cy1 -= ((double)1 / 5) * rangey;
			isImgCorrect = false;
			break;
		case 'l':
			rangex = cx1 - cx0;
			cx0 += ((double)1 / 5) * rangex;
			cx1 += ((double)1 / 5) * rangex;
			isImgCorrect = false;
			break;
		case 'h':
			rangex = cx1 - cx0;
			cx0 -= ((double)1 / 5) * rangex;
			cx1 -= ((double)1 / 5) * rangex;
			isImgCorrect = false;
			break;
		case 'z':
			rangex = cx1 - cx0;
			rangey = cy1 - cy0;
			tempcx0 = cx1 - ((double)4 / 5) * rangex;
			tempcy0 = cy1 - ((double)4 / 5) * rangey;
			cx1 = cx0 + ((double)4 / 5) * rangex;
			cy1 = cy0 + ((double)4 / 5) * rangey;
			cx0 = tempcx0;
			cy0 = tempcy0;
			//cout << "z pressed" << endl;
			isImgCorrect = false;
			break;
		case 'u':
			rangex = cx1 - cx0;
			rangey = cy1 - cy0;
			tempcx0 = cx1 - ((double)5 / 4) * rangex;
			tempcy0 = cy1 - ((double)5 / 4) * rangey;
			cx1 = cx0 + ((double)5 / 4) * rangex;
			cy1 = cy0 + ((double)5 / 4) * rangey;
			cx0 = tempcx0;
			cy0 = tempcy0;
			//cout << "z pressed" << endl;
			isImgCorrect = false;
			break;
		case 'i':
			maxIter *= 2;
			cout << "number of iterations: " << maxIter << endl;
			isImgCorrect = false;
			break;
		case 'd':
			maxIter /= 2;
			cout << "number of iterations: " << maxIter << endl;
			isImgCorrect = false;
			break;
		case 'r':
			reset();
			break;
		}
	}
	return 0;
}

int rx0, ry0, rx1, ry1;

void mouseCallBack(int event, int x, int y, int flags, void *userdata)
{
	if (event == EVENT_LBUTTONDOWN)
	{
		//cout << "LButtonDown x: " << x << "\ty: " << y << endl;
		rx0 = x; ry0 = y;
		clicked = true;
	}

	if (event == EVENT_LBUTTONUP)
	{
		//cout << "LButtonUp x: " << x << "\ty: " << y << endl;
		rangex = cx1 - cx0;
		rangey = cy1 - cy0;
		tempcx0 = (double)rx0 / width * rangex + cx0;
		tempcy0 = (double)(height - ry0) / height * rangey + cy0;
		tempcx1 = (double)rx1 / width * rangex + cx0;
		tempcy1 = (double)(height - ry1) / height * rangey + cy0;
		cx0 = min(tempcx0, tempcx1); cx1 = max(tempcx0, tempcx1);
		cy0 = min(tempcy0, tempcy1); cy1 = max(tempcy0, tempcy1);
		//cout << cx0 << ' ' << cy0 << ' ' << cx1 << ' ' << cy1 << endl;
		isImgCorrect = false;
		clicked = false;
	}

	if (event == EVENT_MOUSEMOVE && clicked)
	{
		//cout << "MouseMove x: " << x << "\ty: " << y << endl;
		Mat outputTemp = output.clone();

		rx1 = x; ry1 = ry0 + (((ry0 - y) < 0) ? 1 : -1) * abs(rx0 - x);
		rectangle(outputTemp, Point(rx0, ry0), Point(rx1, ry1), Scalar(255, 255, 255));

		imshow("MandelWindow", outputTemp);
	}
}
