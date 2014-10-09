//g++ -g -O2 -o 2satisfaction 2satisfaction.cpp
#include <iostream>
#include <fstream>
#include <string.h> //strcmp()
#include <stdlib.h>  // atoi()
#include <cmath> // abs(), log2()
#include <ctime>
#include <assert.h>

using namespace std;

class TwoSatisfactionTest {
  public:
    void run();
    void shouldReadInputFile();
    void shouldFindASatisfyingVariablesAssignment();
};

class Clause {
  public:
    int firstVarIndex, secondVarIndex, id;
    bool firstVarNegation, secondVarNegation;
    Clause(int firstVarIndex, int secondVarIndex) {
      this->firstVarIndex = abs(firstVarIndex);
      this->firstVarNegation = firstVarIndex<0 ? true : false;
      this->secondVarIndex = abs(secondVarIndex);
      this->secondVarNegation = secondVarIndex<0 ? true : false;
    };
};

class TwoSatisfaction {
  public:
    int numberOfClauses, numberOfVariables;
    bool* variables;
    Clause** clauses; //later-initialized as array of (pointers to) Clauses
    TwoSatisfaction(const char*);
    bool calculateSatisfiableSetOfVariables();
    void generateRandomInitialAssignment();
    int checkIfVariablesAssignmentSatisfiesAllClauses();
    void simplifyClauses();
};

TwoSatisfaction::TwoSatisfaction(const char* filename) {
  string inputLine;
  ifstream inputFile;

  srand(time(NULL));

  inputFile.open(filename, ios::in);
  if(!inputFile) { cout << "Error open file " << filename << endl; return; }

  getline(inputFile, inputLine);
  this->numberOfClauses = atoi(inputLine.c_str());
  this->numberOfVariables = this->numberOfClauses;
  this->variables = new bool [this->numberOfVariables];
  this->clauses   = new Clause* [this->numberOfClauses];

  int i = 0, pos;
  Clause* clause;
  while (!inputFile.eof()) {
    getline(inputFile, inputLine);
    if(strcmp(inputLine.c_str(), "")==0) break;
    pos = inputLine.find(" ");
    this->clauses[i] = new Clause(atoi(inputLine.substr(0, pos).c_str()), atoi(inputLine.substr(pos+1).c_str()));
    i++;
  }
  inputFile.close();
};

/* Papadimitriou's 2-SAT Algorithm
Repeat log2(n) times:
  - Choose random initial assignment
  - Repeat 2n^2 times:
    - If current assignment satisfies all clauses, halt + report this
    - Else, pick arbitrary unsatisfied clause and flip the value of
    one of its variables [choose between the two uniformly at random]
Report "unsatisfiable" */
bool TwoSatisfaction::calculateSatisfiableSetOfVariables(){
  int variableToFlip;
  float limitOuter = log2(this->numberOfVariables),
        limitInner = 2*pow(this->numberOfVariables, 2);
  cout << "log2(n)=" << limitOuter << "\n";
  cout << "2*(n)^2=" << limitInner << "\n";
  for(int i=1; i <= limitOuter; i++){
    cout << "i=" << i << "\n";
    this->generateRandomInitialAssignment();
    for(int j=1; j <= limitInner; j++){
      if(j%10000==0) cout << "j=" << j << "\n";
      variableToFlip = this->checkIfVariablesAssignmentSatisfiesAllClauses();
      if(variableToFlip == 0) return true; //all clauses are satisfied. Yay!
      this->variables[variableToFlip-1] = !this->variables[variableToFlip-1];
    }
  }
  return false;
};

void TwoSatisfaction::generateRandomInitialAssignment(){
  for(int i=0; i < this->numberOfVariables; i++){
    this->variables[i] = (rand() % 2 == 1); //random "true" or "false" assignment
  }
};

/* Check if variable assignment x1, x2, .. , xn satisfies all supplied clauses:
  (x1 V x2) ^ (!x1 V x3) ^ (x3 V x4) ^ (!x2 V !x4)
  where V - logical OR; ^ - logical AND; ! - logical NOT
  returns 0, if all clauses are satisfied, or a variable, that needs to be flipped
*/
int TwoSatisfaction::checkIfVariablesAssignmentSatisfiesAllClauses(){
  bool clauseVar1, clauseVar2;
  for(int i=0; i < this->numberOfClauses; i++){
    clauseVar1 = this->variables[this->clauses[i]->firstVarIndex-1];
    clauseVar2 = this->variables[this->clauses[i]->secondVarIndex-1];
    if(this->clauses[i]->firstVarNegation) clauseVar1 = !clauseVar1;
    if(this->clauses[i]->secondVarNegation) clauseVar2 = !clauseVar2;

    //if clause is not satisfied, randomly pick 1 var out of clause and return it. 
    if(!(clauseVar1 || clauseVar2)){
      return (rand() % 2 == 1) ? this->clauses[i]->firstVarIndex : this->clauses[i]->secondVarIndex;
    }
  }
  return 0;
};

/*
  Drastically simplify the clauses by applying transitive closure.
  http://en.wikipedia.org/wiki/2-satisfiability#Resolution_and_transitive_closure
  
  Krom (1967):
  Suppose that a 2-satisfiability instance contains two clauses that both use 
  the same variable x, but that x is negated in one clause and not in the other. 
  Then we may combine the two clauses to produce a third clause, having the two
  other terms in the two clauses; this third clause must also be satisfied 
  whenever the first two clauses are both satisfied. 
  For instance, we may combine the clauses (-a or b) and (-b or -c) in this way 
  to produce the clause (a or -c).

  Krom writes that a formula is consistent if repeated application of this 
  inference rule cannot generate both the clauses (x or x) and (-x or -x), for any variable x.
  As he proves, a 2-CNF formula is satisfiable if and only if it is consistent.
  For, if a formula is not consistent, it is not possible to satisfy both 
  of the two clauses (x or x) and (-x or -x) simultaneously.
*/
void TwoSatisfaction::simplifyClauses(){
  for(int i=0; i < this->numberOfVariables; i++){}
};

int printTime(){
  time_t now = time(0);
  cout << ctime(&now);
}

int main(int argc, char* argv[]) {
  const char* filename = argc>1 ? argv[1] : "2sat1.txt";
  cout << "Searching for a satisfiable set of variables for clauses from " << filename << endl;
  printTime();
  // TwoSatisfaction twoSat(filename);
  // bool result = twoSat.calculateSatisfiableSetOfVariables();
  // cout << "The given instance of clauses is " << (result ? "satisfiable" : "not satisfiable") << endl;
  TwoSatisfactionTest test;
  test.run();
  printTime();
  return 0;
}

void TwoSatisfactionTest::run(){
  this->shouldReadInputFile();
  this->shouldFindASatisfyingVariablesAssignment();
}

void TwoSatisfactionTest::shouldReadInputFile(){
  TwoSatisfaction twoSat("tests/test12.txt");
  assert(twoSat.numberOfVariables == 25);
  assert(twoSat.numberOfClauses == 25);
  Clause* clause1 = twoSat.clauses[0];
  Clause* clause2 = twoSat.clauses[24];
  assert(clause1->firstVarIndex == 1);
  assert(clause1->firstVarNegation == false);
  assert(clause1->secondVarIndex == 2);
  assert(clause1->secondVarNegation == true);
  assert(clause2->firstVarIndex == 13);
  assert(clause2->firstVarNegation == false);
  assert(clause2->secondVarIndex == 5);
  assert(clause2->secondVarNegation == false);
};

void TwoSatisfactionTest::shouldFindASatisfyingVariablesAssignment(){
  TwoSatisfaction * twoSat;
  bool result;

  twoSat = new TwoSatisfaction("tests/test1.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);

  twoSat = new TwoSatisfaction("tests/test2.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);

  twoSat = new TwoSatisfaction("tests/test3.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == false);

  twoSat = new TwoSatisfaction("tests/test4.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);

  twoSat = new TwoSatisfaction("tests/test5.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);

  twoSat = new TwoSatisfaction("tests/test6.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);

  twoSat = new TwoSatisfaction("tests/test7.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);

  twoSat = new TwoSatisfaction("tests/test8.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);

  twoSat = new TwoSatisfaction("tests/test9.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == false);

  twoSat = new TwoSatisfaction("tests/test10.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);

  twoSat = new TwoSatisfaction("tests/test11.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == false);

  twoSat = new TwoSatisfaction("tests/test12.txt");
  result = twoSat->calculateSatisfiableSetOfVariables();
  assert(result == true);
};