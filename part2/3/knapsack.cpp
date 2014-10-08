//g++ -g -O2 -o knapsack knapsack.cpp
#include <iostream>
#include <fstream>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <ctime>
using namespace std;

class Item {
  public:
    int value, weight;
    Item(int value, int weight) {
      this->value = value;
      this->weight = weight;
    };
};

class Knapsack {
  public:
    int maxWeight, maxValue, itemsAmount;
    //later-initialized as array of (pointers to) Items
    Item** items;
    Knapsack(const char*);
    void calculateSubsolutions();
};

Knapsack::Knapsack(const char* filename) {
  ifstream inputFile;
  inputFile.open(filename, ios::in);
  if(!inputFile) { cout << "Error open file " << filename << endl; return; }

  int i = 0;
  int inputLineNumbers[2];
  int pos;
  string inputLine;
  while (!inputFile.eof()) {
    getline(inputFile, inputLine);
    if(strcmp(inputLine.c_str(), "")==0) break;
    pos = inputLine.find(" ");
    inputLineNumbers[0] = atoi(inputLine.substr(0, pos).c_str());
    inputLineNumbers[1] = atoi(inputLine.substr(pos+1).c_str());
    if(i==0){
      this->maxWeight   = inputLineNumbers[0];
      this->itemsAmount = inputLineNumbers[1];
      this->items = new Item* [this->itemsAmount];
      i++;
      continue;
    }
    this->items[i-1] = new Item(inputLineNumbers[0], inputLineNumbers[1]);
    i++;
  }
  inputFile.close();
}

/*
Dynamic programming algorithm to solve Knapsack problem.
Building the subsolutions matrix. Matrix is not stored completely,
only 2 columns are stored at once (previously computed data can be disposed of).
*/
void Knapsack::calculateSubsolutions() {
  int *subsolutionsOld = new int[this->maxWeight+1];
  int *subsolutionsNew = new int[this->maxWeight+1];
  int i, j, k, value1, value2, prevWeight;
  for(i=0; i<=this->maxWeight; i++) subsolutionsOld[i] = 0;

  for(i=1; i<=this->itemsAmount; i++) {
    cout << i<< "\n";
    for(j=0; j<=this->maxWeight; j++) {
      // case 1. Item i excluded, no additional weight added to knapsack
      value1 = subsolutionsOld[j];
      // case 2. Item i is included, requires adding item's weight to knapsack
      prevWeight = this->items[i-1]->weight;
      value2 = (prevWeight <= j) ? (this->items[i-1]->value + subsolutionsOld[j-prevWeight]) : -1;
      // a total value stored in a knapsack, when i items and j max_knapsack_weight
      subsolutionsNew[j] = (value1>value2) ? value1 : value2;
    }
    for(k=0; k<=this->maxWeight; k++) subsolutionsOld[k] = subsolutionsNew[k];
  }
  this->maxValue = subsolutionsNew[this->maxWeight];
}

int printTime(){
  time_t now = time(0);
  cout << ctime(&now);
}

int main(int argc, char* argv[]) {
  // if(argc<=1) { cout << "Please provide an input file.\n"; return 1; }
  const char* filename = argc>1 ? argv[1] : "knapsack_big.txt";
  printTime();
  Knapsack knapsack(filename);
  knapsack.calculateSubsolutions();
  printTime();
  cout <<"Max total value of items that could be stored in "<<knapsack.maxWeight
       <<" (weight) knapsack is "<<knapsack.maxValue<<" (value).\n";

  // assert(knapsack.maxWeight == 2000);
  // assert(knapsack.items[29]->value == 4);
  // assert(knapsack.items[29]->weight == 555);
  return 0;
}

