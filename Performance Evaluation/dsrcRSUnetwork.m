% DSRC Simulation Parameters
numSimulations = 100; % Number of simulations to calculate the average time
bandwidth = 10e6; % Bandwidth in bits per second (e.g., 10 Mbps for DSRC)
messageSize = 1000 * 8; % Size of the message in bits (e.g., 1000 bytes)
rsuProcessingDelay = 20e-6; % Mean processing delay at RSU in seconds (e.g., 20 microseconds)
rsuProcessingStdDev = 5e-6; % Standard deviation for processing delay at RSU
cloudProcessingDelay = 100e-6; % Mean processing delay at the cloud server in seconds
cloudProcessingStdDev = 20e-6; % Standard deviation for processing delay at cloud
meanNetworkDelay = 5e-6; % Mean additional network delay due to congestion
networkDelayStdDev = 2e-6; % Standard deviation for network delay

% Function to simulate DSRC RSU-to-Cloud communication delay
function delay = dsrcRsuToCloudDelay(bandwidth, messageSize, rsuProcessingDelay, cloudProcessingDelay, meanNetworkDelay, networkDelayStdDev)
    transmissionDelay = messageSize / bandwidth; % Time to transmit the message
    networkDelay = normrnd(meanNetworkDelay, networkDelayStdDev); % Simulated network congestion delay
    delay = transmissionDelay + rsuProcessingDelay + cloudProcessingDelay + networkDelay;
end

% Initialize Results
communicationTimes = zeros(1, numSimulations);

% Simulation Loop
for n = 1:numSimulations
    % Simulate RSU processing delay
    rsuDelay = normrnd(rsuProcessingDelay, rsuProcessingStdDev); % Random processing delay at RSU
    
    % Simulate Cloud processing delay
    cloudDelay = normrnd(cloudProcessingDelay, cloudProcessingStdDev); % Random processing delay at Cloud
    
    % Calculate the communication delay for RSU-to-Cloud
    commDelay = dsrcRsuToCloudDelay(bandwidth, messageSize, rsuDelay, cloudDelay, meanNetworkDelay, networkDelayStdDev);
    
    % Record the communication time in this simulation
    communicationTimes(n) = commDelay;
end

% Calculate and Display Average Communication Time
averageCommTime = mean(communicationTimes);
fprintf('Average DSRC RSU-to-Cloud Communication Time: %.6f seconds\n', averageCommTime);

% Plot the Communication Times for each Simulation
figure;
plot(communicationTimes, '-o');
xlabel('Simulation Index');
ylabel('Communication Time (seconds)');
title('DSRC RSU-to-Cloud Communication Time for Each Simulation');
grid on;
