#pragma once
#include <iostream>
#include <string>
using namespace std;

// ��Ӻ궨������ļ���λ�� 
void error_out(string file, unsigned int linenum);
#define ErrorOut() error_out(__FILE__, __LINE__)
 

bool ReadFile(const char* fileName, string& outFile);