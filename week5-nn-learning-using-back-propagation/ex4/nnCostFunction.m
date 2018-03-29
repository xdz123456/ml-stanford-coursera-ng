function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

Theta = {Theta1, Theta2}; % octave cell arrays

% Setup some useful variables
m = size(X, 1);
L = 3; % no of layers         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


%{

Non vectorized attempt

for i = 1:m
  a = X(i, :);
  
  for l = 1:L
    a = [1 a];
    z = Theta{l} * a';
    a = sigmoid(z)';
  endfor
  
  y_temp = zeros(1, num_labels);
  y_temp(y(i)) = 1;
  
  J += (-y_temp*log(a)') - ((1-y_temp)*log(1-a)');
  
endfor 
%}


% Vectorized attempt

% advance indexing octave, to create binary label outputs
% https://octave.org/doc/v4.2.0/Advanced-Indexing.html
Y = zeros(size(X,1), num_labels);
ind = sub2ind(size(Y), 1:rows(Y), y');
Y(ind) = 1;


% first layer is the activation itself
Z = {X}; 
A = {X}; 

a = X;
for l = 2:L
  a = [ones(size(a,1),1) a]; % adding bias unit to each training example
  z = Theta{l-1} * a';
  Z{l} = z;
  a = sigmoid(z)';
  A{l} = a;
endfor

J = sum(((-Y .* log(A{L})) - ((1-Y) .* log(1-A{L})))(:));

% regularisation
reg = 0;
for l = 1:L-1
  reg += sum(((Theta{l}(:,2:end)).^2)(:)); % exclude bias
endfor

J= (J + reg*lambda*.5)/m;


% -------------------------------------------------------------
% delta only exists for 2...L
delta = {};
delta{L} = A{L} - Y;
l = L-1;
while (l > 1)
  % we don't include bias in delta calculations
  del = delta{l+1} * Theta{l}(:, 2:end) .* sigmoidGradient(Z{l})';
  delta{l} = del;
  l--;
endwhile

% accumulator only exists for 1...L-1
accumulator = {};
for l=1:L-1
  % we consider bias in accumulator
  accumulator{l} = (delta{l+1}'* [ones(rows(A{l}),1) A{l}])/m;
  accumulator{l}(:,2:end) += lambda*Theta{l}(:,2:end)/m;  
endfor

Theta1_grad = accumulator{1};
Theta2_grad = accumulator{2};
% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
