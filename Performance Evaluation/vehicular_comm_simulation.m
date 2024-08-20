% Simulation parameters
numVehicles = 20; % Total number of vehicles
numLanes = 2; % Two-way road (one lane each direction)
roadLength = 1000; % Length of the road in meters
simulationTime = 10; % Total simulation time in seconds
timeStep = 0.1; % Time step for each simulation iteration
laneWidth = 3.5; % Width of each lane in meters
safeDistance = 10; % Safe distance to maintain between vehicles in meters
communicationRange = 300; % Increased range for DSRC and C-V2X

% Control variable for assigning malformed certificates
assignMalformedCertificates = 1; % Set to 1 to assign malformed certificates, 0 for normal simulation

% Initialize vehicle positions, speeds, and communication types
vehiclePositions = [rand(numVehicles, 1) * roadLength, repmat((1:numLanes)', numVehicles/numLanes, 1) * laneWidth]; % Random positions along the road
vehicleSpeeds = 8.33 + rand(numVehicles, 1) * (30 - 8.33); % Random speeds between 30 km/h (8.33 m/s) and 30 m/s
vehicleTypes = repmat(["DSRC"; "C-V2X"], numVehicles / 2, 1); % Mixed types of vehicles
vehicleTypes = vehicleTypes(randperm(numVehicles)); % Shuffle to mix vehicle types
vehicleDirections = [repmat(1, numVehicles/2, 1); repmat(-1, numVehicles/2, 1)]; % 1 for right, -1 for left

% Ensure each lane contains vehicles moving in one direction
for i = 1:numVehicles
    if mod(i, 2) == 0
        vehiclePositions(i, 2) = laneWidth; % Vehicles in lane 1 (top lane)
        vehicleDirections(i) = 1; % Right direction
    else
        vehiclePositions(i, 2) = 2 * laneWidth; % Vehicles in lane 2 (bottom lane)
        vehicleDirections(i) = -1; % Left direction
    end
end

% Generate cryptographic keys for each vehicle (public/private key pairs)
keys = cell(numVehicles, 2);
certificates = cell(numVehicles, 1);
for i = 1:numVehicles
    keys{i, 1} = randi([1, 2^16], 1); % Private key (simplified)
    keys{i, 2} = keys{i, 1}; % Public key (simplified, for demonstration)
    certificates{i} = keys{i, 2}; % Simplified certificate containing the public key
end

% Function to sign a message (simplified for demonstration)
function signature = signMessage(message, privateKey)
    signature = mod(sum(message) * privateKey, 2^16); % Simplified signature
end

% Function to verify a message signature (simplified for demonstration)
function isValid = verifyMessage(message, signature, publicKey)
    isValid = (mod(sum(message) * publicKey, 2^16) == signature); % Simplified verification
end

% Function to convert message to binary
function binaryMessage = messageToBinary(message)
    binaryMessage = [];
    for i = 1:length(message)
        binaryMessage = [binaryMessage, dec2bin(typecast(single(message(i)), 'uint8'), 8) - '0'];
    end
    binaryMessage = binaryMessage(:)'; % Convert to row vector
end

% Conditionally assign malformed certificates
if assignMalformedCertificates == 1
    % Randomly pick 1-3 vehicles to have malformed certificates
    numMalformed = randi([1, 3], 1);
    malformedVehicles = randperm(numVehicles, numMalformed);
    for i = malformedVehicles
        certificates{i} = randi([1, 2^16], 1); % Assign a random malformed public key
    end
end

% Initialize log for communications
communicationLog = {};

% Plot initial positions
figure;
hold on;
scatter(vehiclePositions(vehicleDirections == 1 & vehicleTypes == "DSRC", 1), vehiclePositions(vehicleDirections == 1 & vehicleTypes == "DSRC", 2), 'b', 'filled');
scatter(vehiclePositions(vehicleDirections == 1 & vehicleTypes == "C-V2X", 1), vehiclePositions(vehicleDirections == 1 & vehicleTypes == "C-V2X", 2), 'g', 'filled');
scatter(vehiclePositions(vehicleDirections == -1 & vehicleTypes == "DSRC", 1), vehiclePositions(vehicleDirections == -1 & vehicleTypes == "DSRC", 2), 'r', 'filled');
scatter(vehiclePositions(vehicleDirections == -1 & vehicleTypes == "C-V2X", 1), vehiclePositions(vehicleDirections == -1 & vehicleTypes == "C-V2X", 2), 'm', 'filled');
legend('DSRC Right', 'C-V2X Right', 'DSRC Left', 'C-V2X Left');
title('Initial Vehicle Positions');
xlabel('X Position (m)');
ylabel('Y Position (m)');
xlim([0 roadLength]);
ylim([0 (numLanes + 1) * laneWidth]);
hold off;

% Simulation loop
for t = 0:timeStep:simulationTime
    % Create a copy of vehicle positions and speeds to simulate simultaneous communication
    newPositions = vehiclePositions;
    newSpeeds = vehicleSpeeds;
    
    % Vehicle-to-Vehicle Communication and Speed Adjustment
    for i = 1:numVehicles
        for j = 1:numVehicles
            if i ~= j && vehiclePositions(i, 2) == vehiclePositions(j, 2) % Same lane
                distance = abs(vehiclePositions(j, 1) - vehiclePositions(i, 1));
                if distance < communicationRange
                    % Simulate DSRC and C-V2X communication
                    if vehicleTypes(j) == "DSRC"
                        % DSRC communication (using WLAN System Toolbox)
                        cfgDSRC = wlanNonHTConfig('ChannelBandwidth', 'CBW20'); % Use 20 MHz configuration
                        message = [vehiclePositions(j, 1), vehicleSpeeds(j)];
                        binaryMessage = messageToBinary(message); % Convert message to binary
                        waveform = wlanWaveformGenerator(binaryMessage, cfgDSRC);
                        % Downsample to simulate 10 MHz channel
                        waveform = resample(waveform, 1, 2);
                        % Simulate reception (assuming perfect channel)
                        rxWaveform = resample(waveform, 2, 1);
                        % Assuming perfect reception
                        rxMessage = binaryMessage; % Placeholder for actual reception logic
                    elseif vehicleTypes(j) == "C-V2X"
                        % C-V2X communication (using LTE/5G Toolbox)
                        enb = struct();
                        enb.NDLRB = 6;
                        enb.CyclicPrefix = 'Normal';
                        enb.DuplexMode = 'FDD';
                        enb.CellRefP = 1;
                        enb.NSubframe = 0;
                        enb.NCellID = 10;
                        message = [vehiclePositions(j, 1), vehicleSpeeds(j)];
                        txWaveform = lteOFDMModulate(enb, lteDLResourceGrid(enb, message));
                        % Simulate reception
                        rxWaveform = txWaveform; % Assume perfect channel for simplicity
                        rxResourceGrid = lteOFDMDemodulate(enb, rxWaveform);
                        rxMessage = lteExtractResources(1:length(message), rxResourceGrid);
                    end
                    
                    % Sign the message from vehicle j
                    signature = signMessage(message, keys{j, 1});
                    
                    % Log the communication
                    logEntry = struct('time', t, 'sender', j, 'receiver', i, 'message', message, 'signature', signature);
                    
                    % Verify the message signature using the sender's certificate (public key)
                    if verifyMessage(message, signature, certificates{j})
                        % Add authentication result to log
                        logEntry.authenticated = true;
                        % Adjust speed based on received information
                        if vehicleDirections(i) == vehicleDirections(j) && distance > 0 && distance < safeDistance
                            newSpeeds(i) = min(vehicleSpeeds(i), vehicleSpeeds(j));
                        end
                    else
                        % Add authentication result to log
                        logEntry.authenticated = false;
                    end
                    
                    % Append log entry to the communication log
                    communicationLog{end+1} = logEntry;
                end
            end
        end
    end
    
    % Update positions and speeds for the next time step
    for i = 1:numVehicles
        vehicleSpeeds(i) = newSpeeds(i);
        vehiclePositions(i, 1) = vehiclePositions(i, 1) + vehicleSpeeds(i) * vehicleDirections(i) * timeStep;
        
        % Ensure vehicles stay within the road boundaries and handle direction change at boundaries
        if vehiclePositions(i, 1) > roadLength
            vehiclePositions(i, 1) = vehiclePositions(i, 1) - roadLength;
        elseif vehiclePositions(i, 1) < 0
            vehiclePositions(i, 1) = vehiclePositions(i, 1) + roadLength;
        end
    end
    
    % Visualization of vehicle positions at each time step
    figure(1);
    clf;
    hold on;
    scatter(vehiclePositions(vehicleDirections == 1 & vehicleTypes == "DSRC", 1), vehiclePositions(vehicleDirections == 1 & vehicleTypes == "DSRC", 2), 'b', 'filled');
    scatter(vehiclePositions(vehicleDirections == 1 & vehicleTypes == "C-V2X", 1), vehiclePositions(vehicleDirections == 1 & vehicleTypes == "C-V2X", 2), 'g', 'filled');
    scatter(vehiclePositions(vehicleDirections == -1 & vehicleTypes == "DSRC", 1), vehiclePositions(vehicleDirections == -1 & vehicleTypes == "DSRC", 2), 'r', 'filled');
    scatter(vehiclePositions(vehicleDirections == -1 & vehicleTypes == "C-V2X", 1), vehiclePositions(vehicleDirections == -1 & vehicleTypes == "C-V2X", 2), 'm', 'filled');
    legend('DSRC Right', 'C-V2X Right', 'DSRC Left', 'C-V2X Left');
    title(['Vehicle Positions at Time = ' num2str(t) ' seconds']);
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    xlim([0 roadLength]);
    ylim([0 (numLanes + 1) * laneWidth]);
    pause(0.1);
    hold off;
end

disp('Simulation completed.');

% Convert communication log to a table for better readability
logTable = struct2table([communicationLog{:}]);

% Write the log to a CSV file
writetable(logTable, 'communication_log.csv');

disp('Communication log has been saved to communication_log.csv.');
