Détails paramètres :
#####################
-- Contraintes durant le mouvement :
X lb =  [-inf, -inf, -inf, -inf, -pi/4, -inf, -0.8, -3.1, -2.25, 0.1]
X ub = [inf, inf, inf, inf, pi/4, inf, 2.25, -0.1, 0.8, 3.1]
V lb =  [-inf, -inf, -inf, -inf, -inf, -inf, -10, -100, -10, -100]
V ub = [inf, inf, inf, inf, inf, inf, 10, 100, 10, 100]
U lb = [-5; -50; -5; -50]
U ub = [5; 50; 5; 50]
+ contraintes de non transpersion

-- Contraintes finales (tilt - Ry bras droit - Ry bras gauche - salto):
lb = [-15°, -inf, -120°, 2*pi - 5°]
ub = [15°, 120°, inf, 2*pi + 5°]

-- Maximum itérations : 3000

-- Objective : minimiser -twist

Détails résultats enregistrés :
################################

1. DMS 8 DL 30 int
2. DMS 10 DL 30 int initial guess Optimal Solution DMS 8 DL (1.)
3. DMS 10 DL 30 int initial guess Optimal Solution DMS 8 DL (1.) sans CnT
4. DMS 10 DL 30 int
5. DMS 10 DL 30 int sans CnT
6. DMS 10 DL 30 int initial guess vitesse Ry = 0
7. DMS 10 DL 30 int temps libre
8. DMS 10 DL 85 int initial guess vitesse Ry = 0 
9. DMS 10 DL 100 int initial guess vitesse Ry = 0 
10. DMS 10 DL 85 int initial guess vitesse Ry = 0 temps libre
11. DMS 10 DL 100 int initial guess vitesse Ry = 0 temps libre
12. DC 10 DL 30 int Legendre 3 
13. DC 10 DL 100 int Legendre 3 
14. DC 10 DL 30 int Legendre 5
15. DC 10 DL 100 int Legendre 5
16. DC Collocation Trapezoïdale 30 int
17. DC Collocation Trapezoïdale 100 int
18. DC Collocation Hermite 30 int
19. DC Collocation Hermite 100 int