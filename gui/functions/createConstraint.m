function [c] = createConstraint(int, range)

lg = int - range;
ug = int + range;
c = [lg ug];
    
end