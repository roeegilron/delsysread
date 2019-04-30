function convertDelsysDirToMat()
dn = uigetdir();
ff = findFilesBVQX(dn,'*.csv'); 
for f = 1:length(ff)
    convertDelsysToMat(ff{f}); 
end
end