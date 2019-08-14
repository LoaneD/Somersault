function obj = createListOrdered(obj, list, best)

listOF = [];
listOF_NO = [];
for i = 1:size(list,1)
    if ismember(list(i,1), obj.opt.listOpt)
        listOF(size(listOF,1)+1,:) = [i, list(i,2), list(i,2)*100/best];
    end
    listOF_NO(i,:) = [i, list(i,2), list(i,2)*100/best];
end
listSortedNO = sortrows(listOF_NO, 2, 'ascend');
obj.results.listValues = listSortedNO;
obj.results.bestNO{1} = '';
obj.results.best{1} = '';
if size(listOF,1)~=0
    listSorted = sortrows(listOF, 2, 'ascend');
    obj.results.best{1} = int2str(listSorted(1, 1));
else
    listSorted = []; 
    obj.results.bestNO{1} = color(int2str(listSortedNO(1, 1)),1);
    obj.results.bestNO{2} = int2str(listSortedNO(1, 1));
end

i = 1;
list95{1} = 'Simulation';
while i <= size(listSorted,1) && percentage(listSorted, i, obj.data.obj)
    list95{i+1} = int2str(listSorted(i, 1));
    i = i + 1;
end
obj.results.listSim95 = list95;

i = 1;
list95NO{1} = 'Simulation';
while i <= size(listSortedNO,1) && percentage(listSortedNO, i, obj.data.obj)
    index = 0;
    if ~ismember(listSortedNO(i,1), obj.opt.listOpt), index = 1; end
    list95NO{i+1} = color(int2str(listSortedNO(i, 1)),index);
    i = i + 1;
end
obj.results.listSim95NO = list95NO;

listAll{1} = 'Simulation';
for i = 1:size(listSorted,1)
    listAll{i+1} = int2str(listSorted(i, 1));
end
obj.results.listSimAll = listAll;

% all simulation even without OS (those without optimal in red) ordered
listAllNO{1} = 'Simulation';
for i = 1:size(listSortedNO,1)
    index = 0;
    if ~ismember(listSortedNO(i,1), obj.opt.listOpt), index = 1; end
    listAllNO{i+1} = color(int2str(listSortedNO(i, 1)),index);
end
obj.results.listSimAllNO = listAllNO;

end

function perc = percentage(list, i, lim)
    if strcmpi(lim, 'twist')
        perc = list(i, 3) >= 95;
    else
        perc = list(i, 3) <= 105;
    end
end