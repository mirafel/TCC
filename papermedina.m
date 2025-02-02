clear

%% HEALTH INDEX EVALUATION
% Read the FIS file
FIS_HI = readfis('Indice_salud_69_230KV_DP.fis');

% Read inputs
ENTRADAS_Chen = xlsread('TransformerData.xlsx', 'HI', 'B2:G16');

% Check and adjust input ranges
ENTRADAS_Chen(:, 5) = min(max(ENTRADAS_Chen(:, 5), 0), 2000); % Ensure Input 5 is within [0, 2000]
ENTRADAS_Chen(:, 6) = min(max(ENTRADAS_Chen(:, 6), 0), 1000); % Ensure Input 6 is within [0, 1000]

% Create the input vector
ENTRADA_Chen = ENTRADAS_Chen(:, 1:6);

% Evaluate the FIS
H_I_Chen = evalfis(FIS_HI, ENTRADA_Chen);

% Write the results to the Excel file
while true
    try
        xlswrite('TransformerData.xlsx', H_I_Chen, 'RI', 'B2');
        break;
    catch
        warning('The file TransformerData.xlsx is not writable. Please close any other applications using the file and press any key to retry.');
        pause;
    end
end

%% FACTOR OF CONSEQUENCE EVALUATION
% Read the FIS file
FIS_FC = readfis('FACTOR_CONSECUENCIAS_TESIS_v2.fis');

% Read inputs
ENTRADAS_FC = xlsread('TransformerData.xlsx', 'FC', 'B19:G33');

% Check and adjust input ranges
ENTRADAS_FC(:, 5) = min(max(ENTRADAS_FC(:, 5), 0), 2000); % Ensure Input 5 is within [0, 2000]
ENTRADAS_FC(:, 6) = min(max(ENTRADAS_FC(:, 6), 0), 1000); % Ensure Input 6 is within [0, 1000]

% Create the input vector
ENTRADA_FCV1 = ENTRADAS_FC(:, 1:6);

% Evaluate the FIS
FC_FC = evalfis(FIS_FC, ENTRADA_FCV1);

% Write the results to the Excel file
while true
    try
        xlswrite('TransformerData.xlsx', FC_FC, 'RI', 'C2');
        break;
    catch
        warning('The file TransformerData.xlsx is not writable. Please close any other applications using the file and press any key to retry.');
        pause;
    end
end

%% RISK EVALUATION
% Read the FIS file
FIS_RISK = readfis('indice_riesgo8.fis');

% Read inputs
ENTRADAS_HI = xlsread('TransformerData.xlsx', 'RI', 'B2:B16'); % Health index data
ENTRADAS_FC = xlsread('TransformerData.xlsx', 'RI', 'C2:C16'); % Consequence factor data

% Create the input vectors
ENTRADA_M0 = ENTRADAS_HI(:, 1);
ENTRADA_M1 = ENTRADAS_FC(:, 1);

% Evaluate the FIS
RI_RI = evalfis(FIS_RISK, [ENTRADA_M0, ENTRADA_M1]);

% Write the results to the Excel file
while true
    try
        xlswrite('TransformerData.xlsx', RI_RI, 'RI', 'D2');
        break;
    catch
        warning('The file TransformerData.xlsx is not writable. Please close any other applications using the file and press any key to retry.');
        pause;
    end
end

%% RISK COMPARISON
ENTRADAS_TP = xlsread('TransformerData.xlsx', 'RI', 'A2:A16'); % Transformer data
ENTRADAS_IR = xlsread('TransformerData.xlsx', 'RI', 'D2:D16'); % Risk index data
ENTRADAS_CH = xlsread('TransformerData.xlsx', 'RI', 'E2:E16'); % HI*FC data

x = [ENTRADAS_HI, ENTRADAS_FC]; % Create matrix with both inputs
y = [ENTRADAS_TP, ENTRADAS_IR]; % Create matrix with both inputs
z = [ENTRADAS_TP, ENTRADAS_CH]; % Create matrix with both inputs
k = 15;                         % Number of units
d = -0.08;                      % Distance for label placement

scatter(x(:, 1), x(:, 2), 60, '^', 'LineWidth', 2);
for k = 1:k
    text((ENTRADAS_HI(k) + d), (ENTRADAS_IR(k)), strcat('T', num2str(k)));
end
hold on;
xlabel('Health Index');
ylabel('Consequence Factor');
grid on;
hold off;

du = [ENTRADAS_IR, ENTRADAS_CH];

for r = 1:15
    dD = sqrt(sum((du(r, 1) - du(r, 2)) .^ 2));
    D(r, 1) = dD;
end

DU = [ENTRADAS_TP, D];

figure(2)
scatter(y(:, 1), y(:, 2), 60, 'o', 'filled', 'LineWidth', 2);
hold on;
scatter(z(:, 1), z(:, 2), 60, 's', 'filled', 'LineWidth', 2);
scatter(DU(:, 1), DU(:, 2), 60, '^', 'filled', 'LineWidth', 2);
xlabel('Transformer');
ylabel('Risk Index');
legend('Proposed Method', 'HI*FC', 'Euclidean Distance', 'Location', 'NE');
grid on;
hold off;