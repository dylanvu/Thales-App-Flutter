import 'dart:math';

double calculateStandardDeviation(List<num> numbers) {
  if (numbers.isEmpty) {
    throw ArgumentError('The list must not be empty.');
  }

  // calculate the average of the numbers
  double sum = 0;
  for (var number in numbers) {
    sum += number;
  }
  double mean = sum / numbers.length;

  // Calculate the sum of squared differences from the mean
  double sumOfSquaredDifferences = 0;
  for (var number in numbers) {
    double difference = number - mean;
    sumOfSquaredDifferences += pow(difference, 2);
  }

  // Calculate the variance
  double variance = sumOfSquaredDifferences / numbers.length;

  // Calculate the standard deviation (square root of the variance)
  double standardDeviation = sqrt(variance);

  return standardDeviation;
}

double calculateRootMeanSquareDifference(List<num> numbers) {
  if (numbers.isEmpty) {
    throw ArgumentError('The list must not be empty.');
  }

  double sumOfSquaredDifferences = 0;

  for (var number in numbers) {
    sumOfSquaredDifferences += pow(number, 2);
  }

  double rootMeanSquareDifference =
      sqrt(sumOfSquaredDifferences / numbers.length);

  return rootMeanSquareDifference;
}
