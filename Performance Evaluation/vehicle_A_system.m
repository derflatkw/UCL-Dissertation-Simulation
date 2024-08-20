% Initialization of DSRC Communication Emulation

% Initialize Vehicle Positions
vehicles = struct('A', struct(), 'B', struct(), 'C', struct());

% Vehicle positions (simplified)
vehicles.A.position = [0, 0]; % Vehicle A is stationary at the origin
vehicles.B.position = [10, 0]; % Vehicle B is 10 meters away from A
vehicles.C.position = [20, 0]; % Vehicle C is 20 meters away from A

% Pseudonym Certificates (Simplified Example)
vehicles.A.certificate = struct('publicKey', randi([1, 2^16]), 'pseudonym', 'CertA');
vehicles.B.certificate = struct('publicKey', randi([1, 2^16]), 'pseudonym', 'CertB');
vehicles.C.certificate = struct('publicKey', randi([1, 2^16]), 'pseudonym', 'CertC');

% Initialize stored certificates in Vehicle A
vehicles.A.storedCertificates = struct();

% DSRC Configuration (for simplicity, using WLAN)
cfgDSRC = wlanNonHTConfig('ChannelBandwidth', 'CBW10');

% Logging Data
log = struct('time', [], 'sender', [], 'receiver', [], 'message', [], 'authenticated', []);

% Function to Simulate Message Signing and Authentication
function signature = signMessage(message, privateKey)
    signature = mod(sum(message) * privateKey, 2^16); % Simplified signature
end

function isValid = verifyMessage(message, signature, publicKey)
    isValid = (mod(sum(message) * publicKey, 2^16) == signature); % Simplified verification
end

% Function to Emulate DSRC Communication
function [authenticated, logEntry, vehicleA] = authenticate(vehicleA, vehicleB)
    % Generate a message (e.g., position) and sign it
    message = vehicleB.position; % Simplified message content
    signature = signMessage(message, vehicleB.certificate.publicKey);
    
    % Vehicle A attempts to authenticate the message from Vehicle B
    isValid = verifyMessage(message, signature, vehicleB.certificate.publicKey);
    
    % Log the transaction
    logEntry = struct('time', now, 'sender', vehicleB.certificate.pseudonym, ...
                      'receiver', vehicleA.certificate.pseudonym, ...
                      'message', message, 'authenticated', isValid);
    
    % Update Vehicle A's system based on authentication result
    if isValid
        vehicleA.storedCertificates.(vehicleB.certificate.pseudonym) = vehicleB.certificate;
        authenticated = true;
    else
        authenticated = false;
    end
end

% Emulate Communication Scenario
disp('Vehicle B sends authentication request to Vehicle A.');
[authenticatedB, logEntryB, vehicles.A] = authenticate(vehicles.A, vehicles.B);
log = [log, logEntryB];

if authenticatedB
    disp('Vehicle A authenticated Vehicle B.');
    disp('Vehicle C sends authentication request to Vehicle A.');
    [authenticatedC, logEntryC, vehicles.A] = authenticate(vehicles.A, vehicles.C);
    log = [log, logEntryC];
    if authenticatedC
        disp('Vehicle A authenticated Vehicle C.');
    else
        disp('Vehicle A failed to authenticate Vehicle C.');
    end
else
    disp('Vehicle A failed to authenticate Vehicle B.');
end

% Display and store the log of Vehicle A
logTable = struct2table(log);
disp(logTable);

% Save the log to a file
writetable(logTable, 'vehicle_A_log.csv');

% Display stored certificates in Vehicle A's system
disp('Certificates stored in Vehicle A:');
disp(vehicles.A.storedCertificates);
% Extract the state of Vehicle A's system
vehicleA_state = vehicles.A;

% Save the stored information of Vehicle A to a file
save('vehicle_A_system.mat', 'vehicleA_state');

