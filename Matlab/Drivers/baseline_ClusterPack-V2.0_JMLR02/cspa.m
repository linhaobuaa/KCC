% function cl = cspa(cls,k)
%
% DESCRIPTION
%  Performs CSPA for CLUSTER ENSEMBLES
%
% Copyright (c) 1998-2011 by Alexander Strehl

function cl = cspa(cls,k)

disp('CLUSTER ENSEMBLES using CSPA');

if ~exist('k'),
 k = max(max(cls));
end;

clbs = clstoclbs(cls);
s = clbs' * clbs;

s = checks(s./size(cls,1));
disp('here cspa');
cl = metis(s,k);

