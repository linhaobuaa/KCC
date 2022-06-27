function [sp_mtx, n, m, count] = load_sparse(src_fname)
% Create a Matlab data file
% src_fname: the source file 
% dst_fname: Naming new data file, 0 is default name
% llimit: read lines limitation, 0 is infinit
% OUTPUT: Create a Matlab data file
    % clear 
    % clc
    % Start Timer
    tic
    % basic parameters evaluation
    % if ~ischar(src_fname)
    %     fprintf('Error: Source Path Should be a STRING: %s\n', src_fname)
    %     return;        
    % end
    
    if ~exist(src_fname,'file')
        disp(['Error: Source is not EXIST: ', src_fname])
        return;
    end
    
    % fd = fopen('mm.mat'); % test example
    fd = fopen(src_fname); % open file
    head = textscan(fd,'%u %u %u',1); % read declaration [row, colume, total]
    % n = cell2mat(head(1));
    % m = cell2mat(head(2));
    count = head(3);
    mtx = zeros(cell2mat(head(3)),3); % init matrix 3 * total, [row, colume, wcount]
    % sp_mtx = sparse(1,1,0);   % init sparse matrix

    % init coordinates
    i = 0; 
    mi = 0; % row number of mtx

    while ~feof(fd)
        str = strtrim(fgetl(fd));
        arr = str2num(str);
        len = length(arr);

        % disp(str),
        if len < 2
            continue;
        end
        
        i = i + 1; % loop condition
                
        if mod(len,2) == 1
            disp('ERROR: Length of the data array is odd!')
            disp(['Line Number: ',i])
            disp(['Length: ',len])
            return;
        end
        
        for j = 1:2:len
            mi = mi + 1; 
            % write record into each row of mtx
            mtx(mi,:) = [i,arr(j),arr(j+1)]; 
        end
    end

    fclose(fd);

    % create sparse matrix
    sp_mtx = spconvert(mtx);
    [n,m] = size(sp_mtx);
    
    % End Timer
    disp('Time: ')
    disp(toc)
end