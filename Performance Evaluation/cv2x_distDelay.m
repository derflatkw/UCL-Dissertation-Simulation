% Simulation Parameters
maxDistance = 300; % Maximum distance between vehicles in meters
stepDistance = 1; % Distance step in meters
numSimulations = 10; % Number of simulations per distance to calculate average

% Communication Parameters
dataSize = 8000; % Size of the certificate in bits (e.g., 1 KB = 8000 bits)
bandwidth = 10e6; % Bandwidth in bits per second (e.g., 10 Mbps for C-V2X)
meanProcessingDelay = 100e-6; % Mean processing delay in seconds (e.g., 100 microseconds)
processingStdDev = 20e-6; % Standard deviation for processing delay

% Generate RSA key pair (public and private keys)
keySize = 1024; % Size of the RSA keys (e.g., 1024 bits)
privateKey = java.security.KeyPairGenerator.getInstance('RSA');
privateKey.initialize(keySize);
keyPair = privateKey.genKeyPair();
publicKey = keyPair.getPublic();
privateKey = keyPair.getPrivate();

% Initialize Results
distances = 1:stepDistance:maxDistance;
avgAuthenticationTimes = zeros(1, length(distances));

% Function to calculate total C-V2X delay
function delay = cV2XTotalDelay(distance, dataSize, bandwidth, meanProcessingDelay, stdDev)
    speedOfLight = 3e8; % Speed of light in meters per second
    propagationDelay = distance / speedOfLight;
    processingDelay = normrnd(meanProcessingDelay, stdDev); % Random processing delay
    transmissionDelay = dataSize / bandwidth;
    cellularNetworkDelay = normrnd(100e-6, 10e-6); % Additional cellular network delay
    delay = propagationDelay + processingDelay + transmissionDelay + cellularNetworkDelay;
end

% Simulation Loop for each distance
for d = 1:length(distances)
    distance = distances(d);
    authenticationTimes = zeros(1, numSimulations);
    
    for n = 1:numSimulations
        % Start timer for the authentication process
        tic;
        
        % Simulate C-V2X communication delay for sending the certificate
        pause(cV2XTotalDelay(distance, dataSize, bandwidth, meanProcessingDelay, processingStdDev));
        
        % Step 2: Sign the certificate using the private key
        message = ['Certificate_' num2str(n)]; % Example certificate content
        signatureEngine = java.security.Signature.getInstance('SHA256withRSA');
        signatureEngine.initSign(privateKey);
        signatureEngine.update(uint8(message));
        signature = signatureEngine.sign();
        
        % Simulate C-V2X communication delay for sending the signed certificate
        pause(cV2XTotalDelay(distance, dataSize, bandwidth, meanProcessingDelay, processingStdDev));
        
        % Step 4: Verify the certificate using the public key
        verificationEngine = java.security.Signature.getInstance('SHA256withRSA');
        verificationEngine.initVerify(publicKey);
        verificationEngine.update(uint8(message));
        isVerified = verificationEngine.verify(signature);
        
        % Simulate C-V2X communication delay for sending the verification result
        pause(cV2XTotalDelay(distance, dataSize, bandwidth, meanProcessingDelay, processingStdDev));
        
        % Stop timer and record the authentication time
        authenticationTimes(n) = toc;
        
        % Display verification result (for debugging purposes)
        if ~isVerified
            disp(['Distance ', num2str(distance), ' meters: Certificate ', num2str(n), ' failed to authenticate.']);
        end
    end
    
    % Calculate the average authentication time for this distance
    avgAuthenticationTimes(d) = mean(authenticationTimes);
    fprintf('Average Transmission Time for %d: %.6f seconds\n', d, avgAuthenticationTimes(d));
end

% Calculate and Display Overall Results
figure;
plot(distances, avgAuthenticationTimes, '-o');
xlabel('Distance Between Vehicles (meters)');
ylabel('Average Authentication Time (seconds)');
title('Average Authentication Time vs. Distance Between Vehicles (C-V2X)');
grid on;

% Save the results
save('cV2X_authentication_results.mat', 'distances', 'avgAuthenticationTimes');
