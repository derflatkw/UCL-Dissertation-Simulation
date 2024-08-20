% Simulation Parameters
numVehicles = 50; % Number of certificates to authenticate

% Generate RSA key pair (public and private keys)
keySize = 1024; % Size of the RSA keys (e.g., 1024 bits)
privateKey = java.security.KeyPairGenerator.getInstance('RSA');
privateKey.initialize(keySize);
keyPair = privateKey.genKeyPair();
publicKey = keyPair.getPublic();
privateKey = keyPair.getPrivate();

% Initialize Results
authenticationTimes = zeros(1, numVehicles);

% Simulation Loop
for i = 1:numVehicles
    % Generate a message (certificate) to sign and authenticate
    message = ['Certificate_' num2str(i)]; % Example certificate content
    
    % Start timer for the authentication process
    tic;
    
    % Step 1: Sign the certificate using the private key
    signatureEngine = java.security.Signature.getInstance('SHA256withRSA');
    signatureEngine.initSign(privateKey);
    signatureEngine.update(uint8(message));
    signature = signatureEngine.sign();
    
    % Step 2: Verify the certificate using the public key
    verificationEngine = java.security.Signature.getInstance('SHA256withRSA');
    verificationEngine.initVerify(publicKey);
    verificationEngine.update(uint8(message));
    isVerified = verificationEngine.verify(signature);
    
    % Stop timer and record the authentication time
    authenticationTimes(i) = toc;
    
    % Display verification result (for debugging purposes)
    if ~isVerified
        disp(['Certificate ', num2str(i), ' failed to authenticate.']);
    end
end

% Calculate and Display Results
averageAuthTime = mean(authenticationTimes);
fprintf('Average Authentication Time: %.6f seconds\n', averageAuthTime);

% Plot the Authentication Times for each Certificate
figure;
plot(authenticationTimes, '-o');
xlabel('Certificate Index');
ylabel('Authentication Time (s)');
title('Authentication Time for Each Certificate');
grid on;
