#include <bits/stdc++.h>
using namespace std;

/*
  N < 100000
  1 <= Si < Ei < 10^9

  N
  S0 E0
  S1 E1
  ...
  Si Ei

  ex.
  5
  1 3
  2 5 
  4 7
  6 9
  8 10
 */
int main(int argc, char **argv){

    int N;
    cin >> N;

    vector<long> S(N), E(N);
    for(int i = 0; i < N; i++){
	cin >> S.at(i) >> E.at(i);
    }

    int ans = 0;

    vector<pair<int, int>> T(N);
    for(int i = 0; i < N; i++){
	T.at(i) = make_pair<int,int>(E.at(i), S.at(i));
    }

    sort(T.begin(), T.end());
    
    int time = 0;
    for(int i = 0; i < N; i++){
	pair<int, int> t = T.at(i);
	if(time < t.second){
	    time = t.first;
	    ans++;
	    cout << "do " << t.second << " " << t.first << ", time=" << time << endl;
	}else{
	    cout << "skip " << t.second << " " << t.first << endl;
	}
    }

    cout << ans << endl;
}
