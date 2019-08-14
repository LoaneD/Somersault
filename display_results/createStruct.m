function [struct1, title] = createStruct(str1, varargin)
% Create a structure containing all structure but in input 
% Add fields missing if needed to get equivalent input structures

if nargout == 2
    title{1} = inputname(1);
    for i = 2:nargin
        title{i} = inputname(i);
    end
end

nstructPlus = nargin - 1;
% str1f = fieldnames(str1);
for j=1:nstructPlus
    if j==1, str1f = fieldnames(str1);
    else, str1f = fieldnames(varargin{j-1});
    end
    for i=j:nstructPlus
        Bf = fieldnames(varargin{i});
        x = ismember(Bf,str1f);
        Bft = Bf(~x);
        for k=1:numel(Bft)
            if j==1,str1.(Bft{k}) = 0;
            else,varargin{j-1}.(Bft{k}) = 0;
            end
        end
        y = ismember(str1f,Bf);
        str1ft = str1f(~y);
        for k=1:numel(str1ft)
            varargin{i}.(str1ft{k}) = 0;
        end
    end
end

struct1(1) = str1;
for i=1:nstructPlus
    struct1(i+1) = varargin{i};
end

end
