function [colorHTML] = color(sim, index)

codes = {'black', 'red'};
colorCode = codes{index+1};
% format into HTML code
htmlCode = '<html><span style="color: %s">%s</span></html>';
colorHTML = sprintf(htmlCode,colorCode,sim);

end