% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% COURSEWORK 2: MNIST WRITTEN CHARACTER CLASSIFICATION WITH A MULTI-LAYER
% PERCEPTRON
% AUTHOR: PABLO ACEREDA
% FILE:   

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LINES THAT HAVE TO BE IN EVERY SCRIPT: 
% clear variables, 
% close opened windows 
% and clean the comand windows
%-------------------------------------------------------------------------%
clear variables;
close all;
clc;
%-------------------------------------------------------------------------%

%                               DATASET
%                              =========
% Change the filenames if you've saved the files under different names
% On some platforms, the files might be saved as
% train-images.idx3-ubyte / train-labels.idx1-ubyte
% The datasets obtained from http://yann.lecun.com/exdb/mnist/ are
% concatenated to perform k-folding afterwards.
images = [loadMNISTImages('./dataset/train-images.idx3-ubyte'), ...
          loadMNISTImages('./dataset/t10k-images.idx3-ubyte')];
labels = [loadMNISTLabels('./dataset/train-labels.idx1-ubyte'); ...
          loadMNISTLabels('./dataset/t10k-labels.idx1-ubyte')];

%                             DISPLAY DATA
%                            ==============
% We are using display_network from the autoencoder code
display_network(images(:, 1 : 100)); % Show the first 100 images
disp(labels(1 : 10));

%                       NEURAL NETWORK TRAINING
%                      =========================

% Preparation for different consecutive experiments
numExperiments = 3;
hiddenNum     = [1, 2, 3];
mean_errors    = zeros(length(hiddenNum), numExperiments);
times          = zeros(length(hiddenNum), numExperiments);

% Number of fragments in cross-validation
k_value = 10;
% Data partitioning
[train, test] = crossValidationSet(images, labels, k_value);

% Network Dimesions
inputDim = size(images, 1);
hiddenDim = 10;
outputDim = 10;

for h = 1 : 1 : length(hiddenNum)
    h
    for e = 1 : 1 : numExperiments
        e
        tic 
        % Network creation
        net = MLP(inputDim, hiddenDim, outputDim, hiddenNum(h));
        net = net.initWeight(1.0);

        % Error rate
        error = double(zeros(k_value, 1));

        for k = 1 : 1 : k_value

            images_k = cell2mat(train(k, 1));
            labels_k = cell2mat(train(k, 2));

            for i = 1 : 1 : length(labels_k)
                net.adapt_to_target(images_k(:, i), labels_k(i), 0.1);
            end

            test_images_k = cell2mat(test(k, 1));
            test_labels_k = cell2mat(test(k, 2));

            predictions = zeros(length(test_labels_k), 1);

            for t = 1 : 1 : length(test_labels_k)
                predictions(t) =  net.compute_output(test_images_k(:, t));
            end

            error(k) = computeError(predictions, test_labels_k);

        end

        mean_errors(h, e) = sum(error) / length(error);
        times(h, e) = toc;
    end
end

mean_errors
times

x = [1 : length(hiddenNum)];

figure;
subplot(2, 1, 1)
gscatter(x, mean_errors, x)
xlabel('experiments')
ylabel('errors')
subplot(2, 1, 2)
gscatter(x, times,  x)
xlabel('experiments')
ylabel('times')
legend('off')
