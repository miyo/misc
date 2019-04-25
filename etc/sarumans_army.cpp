/*
 * N (1 < N <= 1000)
 * R (0 <= R <= 1000)
 * {X} (0 <= Xi <= 1000)
 *
 * 6
 * 10
 * 1 7 15 20 30 50
 */

#include <bits/stdc++.h>

using namespace std;

int main(int argc, char **argv)
{
    int N, R;

    cin >> N >> R;
    
    vector<int> X(N);
    for(int i = 0; i < N; i++){
		cin >> X.at(i);
    }

    int ans = 0;

    sort(X.begin(), X.end());

    int cover = 0;
    int id = 0;
    int a = X.at(0);
	int c = X.at(0);
    while(cover < N){
		int r = a + R;
		++ans;
		int i;
		for(i = id; i < N; i++){
	    	if(X.at(i) > r){
				break;
			}
			c = X.at(i);
			++cover;
		}
		r = c + R;
		for(; i < N; i++){
	    	if(X.at(i) > r){
				a = X.at(i);
				break;
			}
			++cover;
		}
		id = i;
    }
     cout << ans << endl;
 }
