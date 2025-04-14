% Root-Finding in MATLAB with Decimal Stability Condition and Error Percentage
clc; clearvars;

% Welcome message
disp('Welcome to NumeriSolve');
input('Press Enter to continue...');

% Prompt user to choose the method
method = input('Choose method: 1 for Bisection Method, 2 for Secant Method, 3 for False Position Method, 4 for Newton-Raphson Method: ');

% Prompt user to input a function as a string
funcStr = input('Enter the function in terms of x (use "exp(x)" for e^x, e.g., exp(x) - 4*x): ', 's');
f = str2func(['@(x) ' funcStr]);  % Convert string to anonymous function

% Define stopping criteria
choice = input('Choose stopping criteria (1 for specific number of iterations, 2 for error tolerance, 3 for decimal stability, 4 for error percentage): ');

if choice == 1
    max_iterations = input('Enter the number of iterations: ');
    tolerance = -1; % Not used when choice is 1
elseif choice == 2
    tolerance = input('Enter the error tolerance (e.g., 1e-6): ');
    max_iterations = inf; % No iteration limit
elseif choice == 3
    decimal_places = input('Enter the number of decimal places for stability: ');
    max_iterations = inf; % No iteration limit
elseif choice == 4
    error_percentage_criteria = input('Enter the desired error percentage (e.g., 0.01 for 0.01%): ');
    max_iterations = inf; % No iteration limit
else
    error('Invalid choice. Please enter 1, 2, 3, or 4.');
end

% Initialize iteration counter
iteration = 0;

% Variable to store previous approximation for decimal stability and error percentage check
prev_approximation = NaN;
last_x = NaN;  % Variable to store the last approximated root

% Perform the selected method
if method == 1
    %% Bisection Method
    a = input('Enter the start of the interval (a): ');
    b = input('Enter the end of the interval (b): ');
    fprintf('Using Bisection Method...\n');
    error = abs(b - a);
    
    while iteration < max_iterations && (choice ~= 2 || error > tolerance)
        iteration = iteration + 1;
        c = (a + b) / 2;
        
        % Error Percentage Calculation
        if ~isnan(prev_approximation)
            error_percentage = abs((c - prev_approximation) / c) * 100;
        else
            error_percentage = NaN;
        end
        
        % Check if root is found or tolerance criteria is met
        if f(c) == 0 || (choice == 2 && error < tolerance) || (choice == 4 && error_percentage < error_percentage_criteria)
            fprintf('Root found at x = %.4f with f(x) = %.4f\n', c, f(c));
            last_x = c;
            break;
        elseif f(a) * f(c) < 0
            b = c;
        else
            a = c;
        end
        error = abs(b - a);
        
        % Decimal stability check
        if choice == 3 && ~isnan(prev_approximation) && round(c, decimal_places) == round(prev_approximation, decimal_places)
            fprintf('Decimal stability reached with %.0f decimal places. Approximate root is x = %.4f\n', decimal_places, c);
            last_x = c;
            break;
        end
        prev_approximation = c;
        last_x = c;

        fprintf('Iteration %d: Interval = [%.4f, %.4f], Midpoint = %.4f, f(c) = %.4f, Error = %.4f, Error Percentage = %.4f%%\n', iteration, a, b, c, f(c), error, error_percentage);
    end

elseif method == 2
    %% Secant Method
    a = input('Enter the start of the interval (a): ');
    b = input('Enter the end of the interval (b): ');
    fprintf('Using Secant Method...\n');
    x0 = a; 
    x1 = b; 
    error = inf;

    % Initial error percentage calculation based on x0 and x1
    error_percentage = abs((x1 - x0) / x1) * 100;

    while iteration < max_iterations && (choice ~= 2 || error > tolerance)
        iteration = iteration + 1;
        
        if f(x1) - f(x0) == 0
            fprintf('Division by zero detected. Secant Method failed.\n');
            break;
        end
        x2 = x1 - f(x1) * (x1 - x0) / (f(x1) - f(x0));
        error = abs(x2 - x1);

        % Error Percentage Calculation
        error_percentage = abs((x2 - x1) / x2) * 100;
        
        if choice == 4 && error_percentage < error_percentage_criteria
            fprintf('Desired error percentage reached. Approximate root is x = %.4f\n', x2);
            last_x = x2;
            break;
        end
        
        x0 = x1; 
        x1 = x2;
        last_x = x2;

        % Decimal stability check
        if choice == 3 && ~isnan(prev_approximation) && round(x2, decimal_places) == round(prev_approximation, decimal_places)
            fprintf('Decimal stability reached with %.0f decimal places. Approximate root is x = %.4f\n', decimal_places, x2);
            break;
        end
        prev_approximation = x2;

        fprintf('Iteration %d: x = %.4f, f(x) = %.4f, Error = %.4f, Error Percentage = %.4f%%\n', iteration, x2, f(x2), error, error_percentage);
    end

elseif method == 3
    %% False Position Method
    a = input('Enter the start of the interval (a): ');
    b = input('Enter the end of the interval (b): ');
    fprintf('Using False Position Method...\n');
    error = abs(b - a);
    
    while iteration < max_iterations && (choice ~= 2 || error > tolerance)
        iteration = iteration + 1;
        c = b - (f(b) * (b - a)) / (f(b) - f(a));
        
        % Error Percentage Calculation
        if ~isnan(prev_approximation)
            error_percentage = abs((c - prev_approximation) / c) * 100;
        else
            error_percentage = NaN;
        end

        if f(c) == 0 || (choice == 2 && error < tolerance) || (choice == 4 && error_percentage < error_percentage_criteria)
            fprintf('Root found at x = %.4f with f(x) = %.4f\n', c, f(c));
            last_x = c;
            break;
        elseif f(a) * f(c) < 0
            b = c;
        else
            a = c;
        end
        error = abs(b - a);

        % Decimal stability check
        if choice == 3 && ~isnan(prev_approximation) && round(c, decimal_places) == round(prev_approximation, decimal_places)
            fprintf('Decimal stability reached with %.0f decimal places. Approximate root is x = %.4f\n', decimal_places, c);
            break;
        end
        prev_approximation = c;
        last_x = c;

        fprintf('Iteration %d: Interval = [%.4f, %.4f], Point = %.4f, f(c) = %.4f, Error = %.4f, Error Percentage = %.4f%%\n', iteration, a, b, c, f(c), error, error_percentage);
    end

elseif method == 4
    %% Newton-Raphson Method
    initial_guess = input('Enter the initial guess: ');
    derivativeStr = input('Enter the derivative of the function in terms of x (e.g., "2*x - 4"): ', 's');
    df = str2func(['@(x) ' derivativeStr]);  % Convert derivative string to function handle
    fprintf('Using Newton-Raphson Method...\n');
    
    x_current = initial_guess;
    error = inf;
    
    while iteration < max_iterations && (choice ~= 2 || error > tolerance)
        iteration = iteration + 1;
        
        % Check for zero derivative
        if df(x_current) == 0
            fprintf('Derivative is zero at x = %.4f. Newton-Raphson Method failed.\n', x_current);
            break;
        end

        % Newton-Raphson formula
        x_next = x_current - f(x_current) / df(x_current);
        error = abs(x_next - x_current);

        % Error Percentage Calculation
        if ~isnan(prev_approximation)
            error_percentage = abs((x_next - prev_approximation) / x_next) * 100;
        else
            error_percentage = NaN;
        end

        % Decimal stability check
        if choice == 3 && ~isnan(prev_approximation) && round(x_next, decimal_places) == round(prev_approximation, decimal_places)
            fprintf('Decimal stability reached with %.0f decimal places. Approximate root is x = %.4f\n', decimal_places, x_next);
            break;
        end
        prev_approximation = x_next;

        % Check for error percentage criteria
        if choice == 4 && error_percentage < error_percentage_criteria
            fprintf('Desired error percentage reached. Approximate root is x = %.4f\n', x_next);
            last_x = x_next;
            break;
        end

        fprintf('Iteration %d: x = %.4f, f(x) = %.4f, Error = %.4f, Error Percentage = %.4f%%\n', iteration, x_next, f(x_next), error, error_percentage);
        
        x_current = x_next;
        last_x = x_next;
    end
else
    error('Invalid method choice. Please enter 1, 2, 3, or 4.');
end

% Plot the function and mark the last iteration point
if ~isnan(last_x)
    x_vals = linspace(last_x - 10, last_x + 10, 1000); % Range around the root
    y_vals = arrayfun(f, x_vals);  % Evaluate function over range
    
    figure;
    plot(x_vals, y_vals, 'b-', 'LineWidth', 1.5); hold on;
    plot(last_x, f(last_x), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');  % Mark the root point
    title('Function Plot with Approximate Root');
    xlabel('x');
    ylabel('f(x)');
    grid on;
    legend('f(x)', 'Approximate Root');
end

disp('Press any key to exit...');
pause;
