Détails paramètres :
#####################
-- Contraintes durant le mouvement :
X lb =  [-inf, -inf, -inf, -inf, -pi/4, -inf, -pi/4, -3.1, -3*pi/4, 0.1]
X ub = [inf, inf, inf, inf, pi/4, inf, 3*pi/4, -0.1, pi/4, 3.1]
V lb =  [-inf, -inf, -inf, -inf, -inf, -inf, -10, -100, -10, -100]
V ub = [inf, inf, inf, inf, inf, inf, 10, 100, 10, 100]
U lb = [-10; -100; -10; -100]
U ub = [10; 100; 10; 100]
+ contraintes de non transpersion

-- Contraintes finales (tilt - Ry bras droit - Ry bras gauche - salto):
lb = [-15°, -inf, -120°, 2*pi - 5°]
ub = [15°, 120°, inf, 2*pi + 5°]

-- Maximum itérations : 3000

-- Objective classique : minimiser -twist
-- Objective pondéré : minimiser -twist + 10*controle Rz + 0.01*controle Ry

Détails résultats enregistrés :
################################
**Folder classique (xx pas 10 simulations)
DMS 10 DL 100 int initial guess vitesse Ry = 0 xx
DMS 10 DL 100 int initial guess vitesse Ry = 0 temps libre xx 
DMS 10 DL 100 int 
DMS 10 DL 100 int temps libre
DMS 10 DL 30 int xx
DMS 10 DL 30 int temps libre xx
DMS 10 DL 30 int somersault speed free xx
DMS 10 DL 100 int somersault speed free xx
DMS 8 DL 30 int
DMS 10 DL 30 int IG solutions optimales 8
DMS 10 DL 30 int IG solutions optimales 8 sans CnT
--
DC Legendre 3 10 DL 30 int xx
DC Collocation Trapezoïdale 30 int
DC Collocation Hermite 30 int
DC Legendre 3 10 DL 100 int xx
DC Collocation Trapezoïdale 100 int
DC Collocation Hermite 100 int

**Folder objective ponderated : les fonctions objectives sont le twist + les contrôles pondérés 
//DMS 8 DL 30 int
DMS 8 DL 100 int
//DMS 10 DL 30 int  
DMS 10 DL 100 int 
//DMS 10 DL 30 int somersault speed free 
DMS 10 DL 100 int somersault speed free
//DMS 10 DL 30 int somersault speed free avec pondération vitesse salto
DMS 10 DL 100 int somersault speed free avec pondération vitesse salto
--
DC Legendre 3 10 DL 30 int 
//DC Collocation Trapezoïdale 30 int
//DC Collocation Hermite 30 int
DC Legendre 3 10 DL 100 int
DC Collocation Trapezoïdale 100 int
DC Collocation Hermite 100 int
--
Collocation avec vitesse libre + avec pondération aussi
DC Collocation Legendre 3 30 int vitesse salto initiale libre
DC Collocation Legendre 3 30 int vitesse salto initiale libre et pondération 0.01
DC Collocation Legendre 3 30 int vitesse salto initiale libre et pondération 0.1
DC Collocation Legendre 3 30 int vitesse salto initiale libre et pondération 1
DC Collocation Legendre 3 30 int vitesse salto initiale libre et pondération 10
