#include <iostream>
#include <string>

using namespace std;

class Pet {
    public:
        string name;
};

string meets(Pet a, Pet b) { return "FALLBACK"; }

void encounter(Pet a, Pet b) {
    string verb = meets(a,b);
    cout << a.name << " meets " << b.name << " and " << verb << endl;
}

class Dog : public Pet {};
class Cat : public Pet {};

string meets(Dog a, Dog b) { return "sniffs"; }
string meets(Dog a, Cat b) { return "chases"; }
string meets(Cat a, Dog b) { return "hisses"; }
string meets(Cat a, Cat b) { return "slinks"; }

int main() {
    Dog fido;     fido.name = "Fido";
    Dog rex;      rex.name = "Rex";
    Cat whiskers; whiskers.name = "Whiskers";
    Cat spots;    spots.name = "Spots";

    encounter(fido, rex);
    encounter(fido, whiskers);
    encounter(whiskers, rex);
    encounter(whiskers, spots);

    return 0;
}