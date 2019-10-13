#include <iostream>
#include <chrono>
#include <iostream>
#include <thread>
#include <time.h>
#include <Windows.h>
#include <vector>
#include <numeric>

using namespace std;
using namespace std::chrono;

//size of the matricies i.e. row and columns for square matrix
static const int M_SIZE = 1024;
//number of total threads available for system - due to change so it can read from file
static const int MAX_THREADS = 10;

class Matrix
{
public:
	//Pointer to a pointer - I am using this instead of the traditional 
	//2D array of integers as the internet says it will allow me to use
	//larger matricies which is the case here: 1024x1024
	int ** data;
	void zeroMatrix()
	{
		//setting up the first dimension of the matrix
		data = new int*[M_SIZE];
		for (int i = 0; i < M_SIZE; i++)
		{
			//setting up the second dimension of the matrix
			data[i] = new int[M_SIZE];
			for (int j = 0; j < M_SIZE; j++)
			{
				data[i][j] = 0;
			}
		}
	}

	//creates a matrix much like the one above only this time the 
	//data elements being somewhat randomised
	void randomizeMatirx()
	{
		data = new int*[M_SIZE];
		for (int i = 0; i < M_SIZE; i++)
		{
			//setting up the second dimension of the matrix
			data[i] = new int[M_SIZE];
			for (int j = 0; j < M_SIZE; j++)
			{
				data[i][j] = rand() % 100;
			}
		}
	}

	//print function for debugging purposes
	void print() {
		cout << endl;
		for (int i = 0; i < M_SIZE; ++i)
		{
			for (int j = 0; j < M_SIZE; ++j)
			{
				cout << data[i][j] << "\t";
			}
			cout << endl;
		}
	}
};

void matMul(const int numThreads, const Matrix& A, const Matrix& B, Matrix& C);

int main()
{
	const int numIterations = 10;
	vector<int> times;
	int count = 0;
	int t;
	//creating an array of threads
	std::thread threads[MAX_THREADS];
	Matrix A, B, C;

	srand((unsigned int)time(NULL));
	A.randomizeMatirx();
	/*A.print();*/
	Sleep(1000);

	srand((unsigned int)time(NULL));
	B.randomizeMatirx();
	/*B.print();*/
	
	C.zeroMatrix();

	while (count < 10)
	{
		auto start = high_resolution_clock::now();
		for (int i = 0; i < MAX_THREADS; i++)
		{
			threads[i] = std::thread(matMul, i, std::ref(A), std::ref(B), std::ref(C));
		}

		for (int i = 0; i < MAX_THREADS; i++)
		{
			threads[i].join();
		}

		auto stop = high_resolution_clock::now();
		auto duration = duration_cast<milliseconds>(stop - start);
		t = (int)duration.count();
		times.push_back(t);


		/*C.print();*/
		cout << "count has taken " << t << " milliseconds - to execute\n";
		count++;
	}

	double average = std::accumulate(times.begin(), times.end(), 0.0) / times.size();
	cout << "Aveage time: " << average << " milliseconds - to execute\n";

	return 0;

}

void matMul(const int numThreads, const Matrix & A, const Matrix & B, Matrix & C)
{
	int start, end;
	//These are for finding out workload of matrix
	//calculating the number of elements in matrix
	const int numElements = (M_SIZE * M_SIZE);
	//calculating the number of operations each thread has to do
	const int numOperations = (numElements / MAX_THREADS);
	//The operations that are left for someone else to do
	const int extraOperations = (numElements % MAX_THREADS);

	if (numThreads == 0)
	{
		//first thread
		start = numOperations * numThreads;
		end = (numOperations * (numThreads + 1)) + +extraOperations;
	}
	else
	{
		start = (numOperations * numThreads) + extraOperations;
		end = (numOperations * (numThreads + 1)) + +extraOperations;
	}

	//the main loop for matrix multiplication
	for (int i = start; i < end; i++)
	{
		const int rowIndex = i % M_SIZE;
		const int colIndex = i / M_SIZE;
		int temp = 0;
		for (int j = 0; j < M_SIZE; j++)
		{
			temp += A.data[rowIndex][j] * B.data[j][colIndex];
		}
		C.data[rowIndex][colIndex] = temp;
	}
}
