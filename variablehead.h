#ifndef _VARIABLEHEAD_H_
#define _VARIABLEHEAD_H_
#include <map>
#include <stack>
#include <queue>
#include <list>
class chainNode {
	public:
	chainNode(){
		
	}
	chainNode* leftchild;
	chainNode* rightchild;
	int value;		/*此Node的值*/
	std::string oper;	/*此Node的符號*/
	int type;		/*此node是運算符號還是數字*/
					/*1: 數字;2: 符號*/
	
};

class ASTree {
	public:
	ASTree(){}
	chainNode* Root;
	
	void addNode(chainNode* target, chainNode* source, int LorR)/*0: L;1: R*/
	{
		
	}
};

class e {
	public:
	e(int a, std::string b, int c){value=a;name=b;type=c;}
	int type;		/*1: 加減乘除;2: 數字;3: 變數(參數)*/
	int value;
	std::string name;
};

class variable {
		public:
		int Datatype;/*1: boolean;2: integer;3: function;4: variable*/
		int value;
		int isEqual;/*1: 等於0成立; 2: 等於0不成立*/
		std::string Name;/*定義變數時的變數名稱*/
		
		std::map<std::string, int> functionParams;/*定義函數時的參數*/
		std::list<int> funParamPassIn;			/*function call時傳進來的參數*/
		std::list<e> funList;	/*紀錄function用的Queue*/
		int equalNum;			/*紀錄"="後面有幾個參數, 為了傳回function的時候數字要正確*/
		
		
	};
	
#endif