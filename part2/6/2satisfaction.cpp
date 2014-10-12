//g++ -g -O2 -o 2satisfaction 2satisfaction.cpp (-O0 for gdb debug)
#include <iostream>
#include <fstream>
#include <string.h> //strcmp()
#include <stdlib.h>  // atoi()
#include <cmath> // abs(), log2()
#include <ctime>
#include <assert.h>

#include <vector>
#include <list>

using namespace std;

class TwoSatisfactionTest {
  public:
    void run();
    void shouldReadInputFile();
    void shouldGenerateListsOfClausesPerVariable();
    void shouldFindASatisfyingVariablesAssignment();
    void shouldRemoveMeaninglessVariables();
};

class Clause {
  public:
    int firstVarIndex, secondVarIndex, id;
    bool firstVarNegation, secondVarNegation;
    Clause(int id, int firstVarIndex, int secondVarIndex) {
      this->id = id;
      this->firstVarIndex = abs(firstVarIndex);
      this->firstVarNegation = firstVarIndex<0 ? true : false;
      this->secondVarIndex = abs(secondVarIndex);
      this->secondVarNegation = secondVarIndex<0 ? true : false;
    };
    int first(){
      return (this->firstVarNegation) ? -(this->firstVarIndex) : this->firstVarIndex;
    };
    int second(){
      return (this->secondVarNegation) ? -(this->secondVarIndex) : this->secondVarIndex;
    };
    bool sameVariables(){
      if(this->firstVarIndex  == this->secondVarIndex)
        return true;
      return false;
    };
};

class Variable {
  public:
    int id;
    std::list<Clause*> clauses;
    Variable(int id) {
      this->id = id;
    }
};

class TwoSatisfaction {
  public:
    int numberOfClauses, numberOfVariables, clausesCounter;
    bool* variableValues;
    std::list<Clause*> clauses;
    std::vector<Variable*> variables;
    std::list<Variable*> variablesList;
    TwoSatisfaction(const char*);
    bool calculateSatisfiableSetOfVariables();
    void generateRandomInitialAssignment();
    int checkIfVariablesAssignmentSatisfiesAllClauses();

    void applyTransitiveClosure();
    int checkClauseReductionFormulaConsistency(Clause*, Clause*, Clause*);
    Clause* mergeTwoClauses(Clause*, Clause*);

    void removeMeaninglessVariables();
    void removeClause(Clause*);
    void insertClause(Clause*);
    void VariablesArrayToList();
    void printClausesPerVariable();
};

TwoSatisfaction::TwoSatisfaction(const char* filename) {
  srand(time(NULL));

  string inputLine;
  ifstream inputFile;
  inputFile.open(filename, ios::in);
  if(!inputFile) { cout << "Error open file " << filename << endl; return; }
  getline(inputFile, inputLine);
  this->numberOfClauses = atoi(inputLine.c_str());
  this->numberOfVariables = this->numberOfClauses;

  Variable* variable;
  int i=1;
  for(i; i <= this->numberOfVariables; i++){
    variable = new Variable(i);
    this->variables.push_back(variable);
  }

  int pos, firstVarId, secondVarId;
  Clause* clause;
  this->clausesCounter=1;

  while (!inputFile.eof()) {
    getline(inputFile, inputLine);
    if(strcmp(inputLine.c_str(), "")==0) break;
    pos = inputLine.find(" ");
    firstVarId = atoi(inputLine.substr(0, pos).c_str());
    secondVarId = atoi(inputLine.substr(pos+1).c_str());
    clause = new Clause(this->clausesCounter, firstVarId, secondVarId);
    this->clauses.push_back(clause);
    //each variable also contains a list of it's own clauses. This is later used to remove unnecessary clauses
    this->variables[abs(firstVarId)-1]->clauses.push_back(clause);
    this->variables[abs(secondVarId)-1]->clauses.push_back(clause);
    this->clausesCounter++;
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

  this->removeMeaninglessVariables();
  if(this->clauses.empty()) return true;

  float limitOuter = log2(this->variablesList.size());
  float limitInner = 2*pow(this->variablesList.size(), 2);
  cout << "log2(n)=" << limitOuter << "\n";
  cout << "2*(n)^2=" << limitInner << "\n";
  for(int i=0; i <= limitOuter; i++){
    // cout << "i=" << i << "\n";
    this->generateRandomInitialAssignment();
    for(int j=1; j <= limitInner; j++){
      // if(j%10000==0) cout << "j=" << j << "\n";
      variableToFlip = this->checkIfVariablesAssignmentSatisfiesAllClauses();
      if(variableToFlip == 0) return true; //all clauses are satisfied. Yay!
      this->variableValues[variableToFlip-1] = !this->variableValues[variableToFlip-1];
    }
  }
  return false;
};

void TwoSatisfaction::generateRandomInitialAssignment(){
  this->variableValues = new bool [this->numberOfVariables];
  for(int i=0; i < this->numberOfVariables; i++){
    this->variableValues[i] = (rand() % 2 == 1); //random "true" or "false" assignment
  }
};

/* Check if variable assignment x1, x2, .. , xn satisfies all supplied clauses:
  (x1 V x2) ^ (!x1 V x3) ^ (x3 V x4) ^ (!x2 V !x4)
  where V - logical OR; ^ - logical AND; ! - logical NOT
  returns 0, if all clauses are satisfied, or a variable, that needs to be flipped
*/
int TwoSatisfaction::checkIfVariablesAssignmentSatisfiesAllClauses(){
  bool clauseVar1, clauseVar2;
  Clause* clause;
  std::list<Clause*>::iterator clauseIter=this->clauses.begin();
  for (clauseIter; clauseIter != this->clauses.end(); ++clauseIter){
    clause = *clauseIter;
    clauseVar1 = this->variableValues[clause->firstVarIndex-1];
    clauseVar2 = this->variableValues[clause->secondVarIndex-1];
    if(clause->firstVarNegation) clauseVar1 = !clauseVar1;
    if(clause->secondVarNegation) clauseVar2 = !clauseVar2;

    //if clause is not satisfied, randomly pick 1 var out of clause and return it. 
    if(!(clauseVar1 || clauseVar2)){
      return (rand() % 2 == 1) ? clause->firstVarIndex : clause->secondVarIndex;
    }
  }
  return 0;
};

void TwoSatisfaction::VariablesArrayToList(){
  for(int i=0; i<this->variables.size(); i++){
    if(this->variables[i]->clauses.size()>0) this->variablesList.push_back(this->variables[i]);
  }
};

/* If some variable never gets negated (or always gets negated),
  exclude all clauses that variable participates in.
  For ex. var [a] participates only in clauses {a OR -b} AND {a OR d} AND {a OR -f},
  all clauses can be removed, since all 3 can be satisfied by simply setting a=true.

  Runs a number of times (k iterator), since not all meaningless variables can be removed in 1 run.
  For ex. (all clauses appear twice: per each variable, that the clause contains):
  var a: {a, -b}, {-a, c}, {a, c}
  var b: {-b, a} {b, d}
  var c: {-a, c}, {a, c}
  var d: {b, d}
  after first run, it will get rid vars [d] and [c], but not [a] and [b]:
  var a: {a, -b};
  var b: {-b, a}.
  On the second run, it will get rid of [a] and [b] as well.
*/
void TwoSatisfaction::removeMeaninglessVariables(){
  bool meaninglessVar,
       allClausesHavePositiveVar,
       allClausesHaveNegativeVar;
  Clause* clause;
  std::list<Clause*>::iterator clauseIter;

  for(int k=0; k<60; k++) {
    // this->printClausesPerVariable();
    for(int i=0; i<this->variables.size(); i++){
      meaninglessVar = false;
      allClausesHavePositiveVar=true;
      allClausesHaveNegativeVar=true;
      Variable* variable = this->variables[i];
      if(i%1000==0) cout << i << " \n";

      if(variable->clauses.size() < 2) { meaninglessVar = true; }
      if(!meaninglessVar){
        clauseIter = variable->clauses.begin();
        // Iterating over all clauses per variable, and setting flags:
        // 1. allClausesHavePositiveVar to false, if found at least 1 clause, that doesn't have [a];
        // 1. allClausesHaveNegativeVar to false, if found at least 1 clause, that doesn't have [-a].
        for (clauseIter; clauseIter != variable->clauses.end(); ++clauseIter){
          clause = *clauseIter;
          if(clause->first() != variable->id && clause->second() != variable->id)
            allClausesHavePositiveVar = false;
          if(clause->first() != -variable->id && clause->second() != -variable->id)
            allClausesHaveNegativeVar = false;
        };
        if(allClausesHavePositiveVar || allClausesHaveNegativeVar) meaninglessVar = true;
      };
      if(meaninglessVar && variable->clauses.size() > 0){ //remove clauses of this var
        clauseIter = variable->clauses.begin();
        while (clauseIter != variable->clauses.end()) {
          this->removeClause(*clauseIter++);
        }
      };
    };
    cout << "clauses amount: " << this->clauses.size() << ".\n";
  };
  this->VariablesArrayToList();
  cout << "Variables amount: " << this->variablesList.size() << ", clauses amount: " << this->clauses.size() << ".\n";
};

//============================================================================================
//============================================================================================
// TRANSITIVE CLOSURE REDUCTION IS NOT USED.
// .applyTransitiveClosure() method needs properly implemented .checkClauseReductionFormulaConsistency()
// INSTEAD .removeMeaninglessVariables() simplification is used.
//============================================================================================

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
*/
void TwoSatisfaction::applyTransitiveClosure(){
  int i=0;
  this->printClausesPerVariable();
  bool clausesRemoved;
  while(i<this->variables.size()){
    clausesRemoved = false;
    Variable* variable = this->variables[i];
    // cout << " " << variable->id << " ";
    if(variable->clauses.size() < 2) { i++; continue; }

    Clause* clause1;
    Clause* clause2;
    Clause* newClause;
    std::list<Clause*>::iterator clauseIter1, clauseIter2;
    clauseIter1 = variable->clauses.begin();
    clauseIter2 = variable->clauses.begin();
    for (clauseIter1; clauseIter1 != variable->clauses.end(); ++clauseIter1){
      if(clausesRemoved) break;
      clause1 = *clauseIter1;
      for (clauseIter2; clauseIter2 != variable->clauses.end(); ++clauseIter2){
        if(clausesRemoved) break;
        if(clauseIter1 == clauseIter2) continue;
        clause2 = *clauseIter2;

        newClause = this->mergeTwoClauses(clause1, clause2);
        if(!newClause) continue; //no match
        this->checkClauseReductionFormulaConsistency(clause1, clause2, newClause);

        this->removeClause(clause1);
        this->removeClause(clause2);
        this->insertClause(newClause);

        clausesRemoved = true;
        // restart searching pairs for this->variables[i].
        // Clauses were removed, and iterators clauseIter1 
        // and clauseIter2 are not working properly anymore
        break; 
      }
    }
    if(clausesRemoved==false) i++;
  }
  this->printClausesPerVariable();
  this->VariablesArrayToList();
};

/*
  Krom writes that a formula is consistent if repeated application of the
  inference rule cannot generate both the clauses (x or x) and (-x or -x), for any variable x.
  As he proves, a 2-CNF formula is satisfiable if and only if it is consistent.
  For, if a formula is not consistent, it is not possible to satisfy both 
  of the two clauses (x or x) and (-x or -x) simultaneously.
  Example:
  Clauses {1,2} {-1,-2} {1,-2} {-1,2} can reduce to:
  1. {2,-2} {-2,2} (or {1,-1} {-1,1}): this leads to a satisfiable formula.
  2. {2,2} {-2,-2} (or {1,1} {-1,-1}): this leads to an unsatisfiable formula.
  
  If initial formula can be reduced to an unsatisfiable formula, 
  than the whole instance of 2SAT formula is unsatisfiable.

  FUNCTION NOT FINISHED, and without this check, applyTransitiveClosure() leads to WRONG results.
  (wrong result is verifiable with test3.txt)
*/
int TwoSatisfaction::checkClauseReductionFormulaConsistency(Clause* clause1, Clause* clause2, Clause* newClause){
  if(!newClause->sameVariables()) return true;
  Clause* clausesToCheckFor[2];
  if(newClause->firstVarNegation == false && newClause->secondVarNegation == false){
    // clausesToCheckFor[0] = new Clause(NULL, -newClause->firstVarIndex, -newClause->secondVarIndex);
  } else if (newClause->firstVarNegation == true && newClause->secondVarNegation == true){
    // clausesToCheckFor[0] = new Clause(NULL, newClause->firstVarIndex, newClause->secondVarIndex);
  }
};

Clause* TwoSatisfaction::mergeTwoClauses(Clause* clause1, Clause* clause2){
  if(clause1->firstVarIndex    == clause2->firstVarIndex && 
     clause1->firstVarNegation != clause2->firstVarNegation){
    return new Clause(this->clausesCounter++, clause1->second(), clause2->second());
  } else if (
    clause1->firstVarIndex    == clause2->secondVarIndex && 
    clause1->firstVarNegation != clause2->secondVarNegation){
    return new Clause(this->clausesCounter++, clause1->second(), clause2->first());
  } else if (
    clause1->secondVarIndex    == clause2->firstVarIndex && 
    clause1->secondVarNegation != clause2->firstVarNegation){
    return new Clause(this->clausesCounter++, clause1->first(), clause2->second());
  } else if (
    clause1->secondVarIndex    == clause2->secondVarIndex && 
    clause1->secondVarNegation != clause2->secondVarNegation){
    return new Clause(this->clausesCounter++, clause1->first(), clause2->first());
  };
  return NULL;
};

//============================================================================================
//============================================================================================

void TwoSatisfaction::removeClause(Clause* clause){
  //1. remove from the list of the 1st clause variable
  this->variables[clause->firstVarIndex-1]->clauses.remove(clause);
  //2. remove from the list of the 2nd clause variable
  if(clause->firstVarIndex!=clause->secondVarIndex)
    this->variables[clause->secondVarIndex-1]->clauses.remove(clause);
  //3. from the general list of clauses
  this->clauses.remove(clause);
  delete clause;
};

void TwoSatisfaction::insertClause(Clause* clause){
  //1. insert to the list of the 1st clause variable
  this->variables[clause->firstVarIndex-1]->clauses.push_front(clause);
  //2. insert to the list of the 2nd clause variable
  if(clause->firstVarIndex!=clause->secondVarIndex)
    this->variables[clause->secondVarIndex-1]->clauses.push_front(clause);
  //3. from into the general list of clauses
  this->clauses.push_front(clause);
}

void TwoSatisfaction::printClausesPerVariable(){
  ofstream file;
  file.open ("clauses_per_variable.txt", fstream::app);
  for(int i=0; i<this->variables.size(); i++){
    file << "Variable: " << this->variables[i]->id<< "; ";
    Clause* clause;
    std::list<Clause*>::iterator clauseIter=this->variables[i]->clauses.begin();
    for (clauseIter; clauseIter != this->variables[i]->clauses.end(); ++clauseIter){
      clause = *clauseIter;
      file << "{" << (clause->firstVarNegation ? "-": "") << clause->firstVarIndex
           << "," << (clause->secondVarNegation ? "-": "") << clause->secondVarIndex << "} ";
    }
    file << endl;
  };
  file.close();
};

int printTime(){
  time_t now = time(0);
  cout << ctime(&now);
}

int main(int argc, char* argv[]) {
  const char* filename = argc>1 ? argv[1] : "2sat1.txt";
  cout << "Searching for a satisfiable set of variables for clauses from " << filename << endl;
  printTime();
  TwoSatisfaction twoSat(filename);
  bool result = twoSat.calculateSatisfiableSetOfVariables();
  cout << "The given instance of clauses is " << (result ? "satisfiable" : "not satisfiable") << endl;
  // TwoSatisfactionTest test;
  // test.run();
  printTime();
  return 0;
}

void TwoSatisfactionTest::run(){
  this->shouldReadInputFile();
  this->shouldGenerateListsOfClausesPerVariable();
  this->shouldRemoveMeaninglessVariables();
  this->shouldFindASatisfyingVariablesAssignment();
}

void TwoSatisfactionTest::shouldReadInputFile(){
  TwoSatisfaction twoSat("tests/test12.txt");
  assert(twoSat.numberOfVariables == 25);
  assert(twoSat.numberOfClauses == 25);
  Clause* clause1 = twoSat.clauses.front();
  Clause* clause2 = twoSat.clauses.back();
  assert(clause1->firstVarIndex == 1);
  assert(clause1->firstVarNegation == false);
  assert(clause1->secondVarIndex == 2);
  assert(clause1->secondVarNegation == true);
  assert(clause2->firstVarIndex == 13);
  assert(clause2->firstVarNegation == false);
  assert(clause2->secondVarIndex == 5);
  assert(clause2->secondVarNegation == false);
};

void TwoSatisfactionTest::shouldRemoveMeaninglessVariables(){
  TwoSatisfaction twoSat("tests/test4.txt");
  // twoSat.printClausesPerVariable();
  twoSat.removeMeaninglessVariables();
  
  assert(twoSat.variablesList.size() == 2); //reduced from 4 to 2
  Variable * first = twoSat.variablesList.front();
  assert(first->id == 1);
  Variable * last = twoSat.variablesList.back();
  assert(last->id == 2);
  // twoSat.printClausesPerVariable();
};

void TwoSatisfactionTest::shouldGenerateListsOfClausesPerVariable(){
  TwoSatisfaction twoSat("tests/test6.txt");

  //Variable 1 is in following clauses: {(1,2), (1,-3), (-1,4)}
  Variable* variable = twoSat.variables[0];
  assert(variable->id == 1);
  assert(variable->clauses.size() == 3);
  Clause* clause = variable->clauses.back(); // clause (-1,4)
  assert(clause->id == 5);
  assert(clause->firstVarIndex == 1);
  assert(clause->firstVarNegation == true);
  assert(clause->secondVarIndex == 4);
  assert(clause->secondVarNegation == false);

  //Variable 5 is not present in any clauses
  variable = twoSat.variables[4];
  assert(variable->id == 5);
  assert(variable->clauses.size() == 0);
};

void TwoSatisfactionTest::shouldFindASatisfyingVariablesAssignment(){
  TwoSatisfaction* twoSat;
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