#include <iostream>
#include <chrono>
#include <algorithm>

using namespace std;
using namespace std::chrono;

int main()
{
	const int N = 292;
	const int P = 292;
	const int M = 292;


	int A[N][P], B[P][M], C[N][M];

	int num = 0;
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < P; j++)
		{
			A[i][j] = num * 2;
			num++;
		}
	}

	int numb = 1;
	for (int i = 0; i < P; i++)
	{
		for (int j = 0; j < M; j++)
		{
			B[i][j] = numb * 3;
			numb++;
		}
	}

	auto start = high_resolution_clock::now();
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < M; j++)
		{
			C[i][j] = 0;
			for (int k = 0; k < P; k++)
			{
				C[i][j] = C[i][j] + A[i][k] * B[k][j];
			}
		}
	}
	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<milliseconds>(stop - start);

	cout << "count has taken " << duration.count() << " milliseconds - to execute\n";

	/*The commented out section below this comment is the optimised  KIJ loop of 
	matrix multiplication*/


	//auto start = high_resolution_clock::now();
	//for (int i = 0; i < N; i++)
	//{
	//	for (int j = 0; j < M; j++)
	//	{
	//		C[i][j] = 0;
	//	}
	//}
	//
	//
	//for (int k = 0; k < N; k++)
	//{
	//	for (int i = 0; i < N; i++)
	//	{
	//		int tmp = A[i][k];
	//		for (int j = 0; j < N; j++)
	//		{
	//			C[i][j] += tmp * B[k][j];
	//		}
	//	}
	//}

	//auto stop = high_resolution_clock::now();
	//auto duration = duration_cast<milliseconds>(stop - start);

	//cout << "count has taken " << duration.count() << " milliseconds - to execute\n";

	return 0;

}
