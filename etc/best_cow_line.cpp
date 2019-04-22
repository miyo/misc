/*
 * N (1 <= N <= 2000)
 * S (S = {A, B, ..., Z}
 *
 * ex.
 * 6
 * ACDBCD
 * 
 * 6
 * AZBZAZ
 *
 */

#include <bits/stdc++.h>

using namespace std;

int main(int argc, char **argv){

    int N;
    string S;

    cin >> N;
    cin >> S;

    int b = 0, e= N-1;
    string T("", N);

    for(int i = 0; i < N; i++){
	string r(e-b+1, '*');
	for(int j = 0; j < N-i; j++){
	    r.at(j) = S.at(e-j);
	}
	cout << "\"" << r << "\"" << endl;
	bool flag = true;
	for(int j = 0; j < N-i; j++){
	    cout << "comp: " << S.at(b+j) << "," << r.at(j) << endl;
	    if(S.at(b+j) < r.at(j)){
		break;
	    }else if(S.at(b+j) > r.at(j)){
		flag = false;
		break;
	    }
	}
	if(flag){
	    T.at(i) = S.at(b);
	    b++;
	}else{
	    T.at(i) = S.at(e);
	    e--;
	}
    }
    
    cout << T << endl;
    
}
