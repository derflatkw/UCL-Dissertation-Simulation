% DSRC Simulation Parameters
numVehicles = 50; % Number of vehicles involved in the communication
numSimulations = 100; % Number of simulations to calculate the average time
maxDistance = 300; % Maximum distance between vehicles and RSUs in meters

% DSRC Communication Parameters
bandwidth = 10e6; % Bandwidth in bits per second (e.g., 10 Mbps for DSRC)
messageSize = 1000 * 8; % Size of the message in bits (e.g., 1000 bytes)
meanProcessingDelay = 20e-6; % Lower mean processing delay at RSU in seconds (e.g., 20 microseconds)
processingStdDev = 5e-6; % Standard deviation for processing delay
meanNetworkDelay = 2e-6; % Lower mean additional network delay due to congestion
networkDelayStdDev = 1e-6; % Standard deviation for network delay
speedRange = [10, 30]; % Speed of vehicles in meters per second

% Function to simulate DSRC communication delay based on distance and congestion
function delay = dsrcCommunicationDelay(distance, bandwidth, messageSize, meanNetworkDelay, networkDelayStdDev)
    speedOfLight = 3e8; % Speed of light in meters per second
    propagationDelay = distance / speedOfLight; % Time for signal to travel to RSU
    transmissionDelay = messageSize / bandwidth; % Time to transmit the message
    networkDelay = normrnd(meanNetworkDelay, networkDelayStdDev); % Simulated network congestion delay
    delay = propagationDelay + transmissionDelay + networkDelay;
end

% Initialize Results
communicationTimes = zeros(1, numSimulations);

% Simulation Loop
for n = 1:numSimulations
    totalCommTime = 0; % Initialize total communication time for this simulation
    
    for v = 1:numVehicles
        % Randomly assign a speed to the vehicle
        speed = randi(speedRange);
        
        % Calculate dynamic distance based on speed (vehicles moving closer/farther from RSU)
        distance = rand() * maxDistance;
        distance = distance + (rand() * speed - (speed / 2)); % Adding random component based on speed
        
        % Calculate the communication delay for sending the message
        commDelay = dsrcCommunicationDelay(distance, bandwidth, messageSize, meanNetworkDelay, networkDelayStdDev);
        
        % Simulate processing delay at the RSU
        processingDelay = normrnd(meanProcessingDelay, processingStdDev); % Random processing delay
        
        % Total round-trip time for this vehicle
        roundTripTime = 2 * commDelay + processingDelay;
        
        % Accumulate the total communication time
        totalCommTime = totalCommTime + roundTripTime;
    end
    
    % Record the average communication time per vehicle in this simulation
    communicationTimes(n) = totalCommTime / numVehicles;
end

% Calculate and Display Average Communication Time
averageCommTime = mean(communicationTimes);
fprintf('Adjusted DSRC V2I Communication Time: %.6f seconds\n', averageCommTime);

% Plot the Communication Times for each Simulation
figure;
plot(communicationTimes, '-o');
xlabel('Simulation Index');
ylabel('Average Communication Time (seconds)');
title('Adjusted DSRC V2I Communication Time for Each Simulation');
grid on;
