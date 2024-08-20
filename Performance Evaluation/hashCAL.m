% Simulation Parameters
arraySize = 1000; % Number of rows in the array (can be changed later)
numSimulations = 100; % Number of simulations to calculate the average hashing time

% Hashing Algorithm
hashAlgorithm = 'SHA-256'; % Hashing algorithm to use

% Initialize a linear array to store the concatenated hash strings and timestamps
linearArray = strings(arraySize, 1); % Initialize the array

% Populate the linear array with concatenated hash strings and timestamps
for i = 1:arraySize
    % Generate a random string as input for the hash
    randomString = ['RandomString_', num2str(i)];
    
    % Hash the random string using MessageDigest
    md = java.security.MessageDigest.getInstance(hashAlgorithm);
    md.update(uint8(char(randomString))); % Convert string to char array and then to bytes
    hashBytes = md.digest(); % Compute the hash
    hashString = sprintf('%02x', typecast(hashBytes, 'uint8')); % Convert bytes to hex string
    
    % Generate a random timestamp in ISO 8601 format
    timestampString = datestr(now, 'yyyy-mm-ddTHH:MM:SS.FFFZ');
    
    % Concatenate hash and timestamp and store in the linear array
    linearArray(i) = [hashString, timestampString];
end

% Initialize Results
hashingTimes = zeros(1, numSimulations);

% Simulation Loop
for n = 1:numSimulations
    % Start timer for the hashing process
    tic;
    
    % Hash the entire linear array by concatenating all elements
    concatenatedString = strjoin(linearArray, ''); % Concatenate all rows into a single string
    
    % Convert the concatenated string to char array and then to uint8
    concatenatedBytes = uint8(char(concatenatedString));
    
    % Hash the concatenated string using MessageDigest
    md = java.security.MessageDigest.getInstance(hashAlgorithm);
    md.update(concatenatedBytes); % Convert string to bytes and update hash
    finalHash = md.digest(); %#ok<NASGU>
    
    % Stop timer and record the hashing time
    hashingTimes(n) = toc;
end

% Calculate and Display Average Hashing Time
averageHashingTime = mean(hashingTimes);
fprintf('Average Hashing Time for a linear array of size %d: %.6f seconds\n', arraySize, averageHashingTime);

% Plot the Hashing Times for each Simulation
figure;
plot(hashingTimes, '-o');
xlabel('Simulation Index');
ylabel('Hashing Time (seconds)');
title(['Hashing Time for Each Simulation with Array Size ', num2str(arraySize)]);
grid on;
