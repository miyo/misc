#include <bits/stdc++.h>

using namespace std;

int main(int argc, char **argv){

    vector<int> V{500,100,50,10,5,1};
    
    vector<int> C(V.size());
    int A;


    for(int i = 0; i < C.size(); i++){
	cin >> C.at(i);
    }
    reverse(C.begin(), C.end());
    
    cin >> A;

    int sum = 0;
    int rest = A;

    for(int i = 0; i < C.size(); i++){
	/*
	if(C.at(i) == 0) continue;
	int v = V.at(i) * C.at(i);
	if(rest >= v){
	    sum += C.at(i);
	    rest -= v;
	}else{
	    sum += rest / V.at(i);
	    rest = rest % V.at(i);
	}
	*/
	int c = min(rest / V.at(i), C.at(i));
	sum += c;
	rest -= c * V.at(i);
    }
   
    cout << sum << endl;

    
}
