#include <cstdio>
#include <cassert>

using namespace std;

int main() {
    assert(freopen("@FILE@.in", "rt", stdin));
#ifndef DEBUG
    assert(freopen("@FILE@.out", "wt", stdout));
#endif

    return 0;
}
