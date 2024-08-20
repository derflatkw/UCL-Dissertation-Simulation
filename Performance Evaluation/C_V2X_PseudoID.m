% Initialization of C-V2X Communication Emulation

% Initialize Vehicle Positions
vehicles = struct('A', struct(), 'B', struct(), 'C', struct());

% Vehicle positions (simplified)
vehicles.A.position = [0, 0]; % Vehicle A is stationary at the origin
vehicles.B.position = [10, 0]; % Vehicle B is 10 meters away from A
vehicles.C.position = [20, 0]; % Vehicle C is 20 meters away from A

% Generate simplified key pairs using MATLAB's rand functionality
vehicles.A.keyPair = generateSimpleKeyPair();
vehicles.B.keyPair = generateSimpleKeyPair();
vehicles.C.keyPair = generateSimpleKeyPair();

% Pseudonym Certificates (Simplified Example)
vehicles.A.certificate = struct('publicKey', vehicles.A.keyPair.publicKey, 'pseudonym', 'CertA');
vehicles.B.certificate = struct('publicKey', vehicles.B.keyPair.publicKey, 'pseudonym', 'CertB');
vehicles.C.certificate = struct('publicKey', vehicles.C.keyPair.publicKey, 'pseudonym', 'CertC');

% Initialize stored certificates in Vehicle A
vehicles.A.storedCertificates = containers.Map();

% Logging Data
log = struct('time', [], 'sender', [], 'receiver', [], 'message', [], 'authenticated', []);

% Function to Generate Simplified Key Pair
function keyPair = generateSimpleKeyPair()
    keyPair.publicKey = randi([1, 2^16]); % Simplified public key
    keyPair.privateKey = randi([1, 2^16]); % Simplified private key
end

% Function to Simulate Message Signing
function signature = signMessageSimple(message, privateKey)
    % Convert message to a numeric representation (sum of elements)
    messageSum = sum(message(:)); 
    signature = mod(messageSum * privateKey, 2^16); % Simplified signature calculation
end

% Function to Verify Message Signature
function isValid = verifyMessageSimple(message, signature, publicKey)
    % Convert message to a numeric representation (sum of elements)
    messageSum = sum(message(:)); 
    isValid = (mod(messageSum * publicKey, 2^16) == signature); % Simplified verification calculation
end

% Function to Emulate Authentication without Transmission Simulation
function [authenticated, logEntry, vehicleA] = authenticate(vehicleA, vehicleB)
    % Generate a message (e.g., position) and sign it
    message = vehicleB.position; % Simplified message content
    signature = signMessageSimple(message, vehicleB.keyPair.privateKey);
    
    % Debugging Output
    disp(['Vehicle ', vehicleB.certificate.pseudonym, ' signed message: ', mat2str(message), ' with signature: ', num2str(signature)]);
    
    % Vehicle A attempts to authenticate the message from Vehicle B
    isValid = verifyMessageSimple(message, signature, vehicleB.certificate.publicKey);
    
    % Log the transaction
    logEntry = struct('time', now, 'sender', vehicleB.certificate.pseudonym, ...
                      'receiver', vehicleA.certificate.pseudonym, ...
                      'message', mat2str(message), 'authenticated', isValid);
    
    % Update Vehicle A's system based on authentication result
    if isValid
        disp(['Vehicle ', vehicleA.certificate.pseudonym, ' authenticated vehicle ', vehicleB.certificate.pseudonym]);
        vehicleA.storedCertificates(vehicleB.certificate.pseudonym) = vehicleB.certificate;
        authenticated = true;
    else
        disp(['Vehicle ', vehicleA.certificate.pseudonym, ' failed to authenticate vehicle ', vehicleB.certificate.pseudonym]);
        authenticated = false;
    end
end

% Emulate Communication Scenario
disp('Vehicle B sends authentication request to Vehicle A.');
[authenticatedB, logEntryB, vehicles.A] = authenticate(vehicles.A, vehicles.B);
log = [log; logEntryB];

if authenticatedB
    disp('Vehicle A authenticated Vehicle B.');
    disp('Vehicle C sends authentication request to Vehicle A.');
    [authenticatedC, logEntryC, vehicles.A] = authenticate(vehicles.A, vehicles.C);
    log = [log; logEntryC];
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

% Extract the state of Vehicle A's system
vehicleA_state = vehicles.A;

% Display stored certificates in Vehicle A's system
disp('Certificates stored in Vehicle A:');
disp(vehicleA_state.storedCertificates);

% Save the stored information of Vehicle A to a file named C_V2X_PseudoID.mat
save('C_V2X_PseudoID.mat', 'vehicleA_state');
