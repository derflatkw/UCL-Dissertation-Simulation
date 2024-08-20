% Simulation Parameters
numSimulations = 1000; % Number of simulations to calculate the average hashing time
hashAlgorithm = 'SHA-256'; % Choose hashing algorithm (e.g., 'SHA-256')

% Example Certificate Content
certificateContent = 'This is an example certificate content for hashing';
certificateBytes = uint8(certificateContent); % Convert to bytes

% Initialize Results
hashingTimes = zeros(1, numSimulations);

% Simulation Loop
for n = 1:numSimulations
    % Start timer for the hashing process
    tic;
    
    % Create a MessageDigest instance
    md = java.security.MessageDigest.getInstance(hashAlgorithm);
    
    % Perform the hashing
    md.update(certificateBytes);
    hashedCertificate = typecast(md.digest(), 'uint8');
    
    % Stop timer and record the hashing time
    hashingTimes(n) = toc;
end

% Calculate and Display Average Hashing Time
averageHashingTime = mean(hashingTimes);
fprintf('Average Hashing Time using %s: %.6f seconds\n', hashAlgorithm, averageHashingTime);

% Plot the Hashing Times for each Simulation
figure;
plot(hashingTimes, '-o');
xlabel('Simulation Index');
ylabel('Hashing Time (seconds)');
title(['Hashing Time for Each Simulation using ', hashAlgorithm]);
grid on;
