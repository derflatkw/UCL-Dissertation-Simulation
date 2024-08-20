% Simulation Parameters
numVehicles = 100; % Number of vehicles entering the zone
networkLatency = 0.01; % Latency in seconds for network communication (e.g., 10ms)
processingTime = 0.05; % Time in seconds for cloud server to process authentication (e.g., 50ms)
calSize = 100; % Initial size of the CAL
calUpdateTime = 0.02; % Time in seconds to update and distribute CAL (e.g., 20ms)

% Initialize Results
authenticationTimes = zeros(1, numVehicles);
calUpdateTimes = zeros(1, numVehicles);

% Simulation Loop
for i = 1:numVehicles
    % Step 1: Vehicle sends authentication request to cloud server
    tic; % Start timer for authentication time
    
    % Simulate network delay
    pause(networkLatency);
    
    % Step 2: Cloud server processes the request and updates CAL
    pause(processingTime);
    
    % Record authentication time
    authenticationTimes(i) = toc; % End timer for authentication time
    
    % Step 3: CAL update and distribution
    tic; % Start timer for CAL update time
    
    % Simulate CAL update time based on the current CAL size
    pause(calUpdateTime + 0.001 * calSize); % CAL update time grows with CAL size
    
    % Record CAL update time
    calUpdateTimes(i) = toc; % End timer for CAL update time
    
    % Increment CAL size to simulate growing CAL
    calSize = calSize + 1;
end

% Calculate and Display Results
meanAuthTime = mean(authenticationTimes);
meanCalUpdateTime = mean(calUpdateTimes);

fprintf('Average Authentication Time: %.3f seconds\n', meanAuthTime);
fprintf('Average CAL Update Time: %.3f seconds\n', meanCalUpdateTime);

% Plot Results
figure;
subplot(2,1,1);
plot(authenticationTimes, '-o');
xlabel('Vehicle Index');
ylabel('Authentication Time (s)');
title('Authentication Time for Each Vehicle');

subplot(2,1,2);
plot(calUpdateTimes, '-o');
xlabel('Vehicle Index');
ylabel('CAL Update Time (s)');
title('CAL Update Time for Each Vehicle');
