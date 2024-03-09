import 'dart:math';

import 'package:flutter/material.dart';

// Higher RMSSD and SDNN values are generally associated with better overall health and greater heart rate variability, which is often seen as a sign of a healthy autonomic nervous system.

// call this function for stress level calculation based on an array of heart rate data
enum StressLevel { NULL, LOW, NORMAL, HIGH }

final List<String> stressLevelToString = ["LOW", "NORMAL", "HIGH"];

class Stress {
  final StressLevel stressLevel;
  final double rmssd;

  Stress(this.stressLevel, this.rmssd);
}

Stress stressLevelCalculation(List<double> numbers) {
  StressLevel stressLevel = StressLevel.NULL;

  int highStressThreshold = 20;
  int lowStressThreshold = 80;

  double rmssd = calculateRootMeanSquareDifference(numbers);

  if (rmssd <= highStressThreshold) {
    stressLevel = StressLevel.HIGH;
  } else if (rmssd >= lowStressThreshold) {
    stressLevel = StressLevel.LOW;
  } else {
    stressLevel = StressLevel.NORMAL;
  }

  return Stress(stressLevel, rmssd);
}

/// this function will take in a list of numbers to generate a new entry from, calculate the new value, then add it to the input list
/// sourceNumbers: numbers to generate a new value from using numFunct
/// numFunct: the function used to generate a new value
/// currentNumbers: the current numbers in the array that we will be graphing
/// maxLength: the array will be be at most this many elements long
/// Example usage: stress = addEntryToList(heartRateTimeDifferences, calculateStandardDeviation, stress, 5)
List<double> addEntryToList(
    List<double> sourceNumbers,
    double Function(List<double> numbers) numFunct,
    List<double> currentNumbers,
    int maxLength) {
  // use the source numbers to calculate a new value off of
  double newValue = numFunct(sourceNumbers);
  // add this new value to the list of numbers and return it
  currentNumbers.add(newValue);
  if (currentNumbers.length > maxLength) {
    // remove the first value of currentNumbers
    currentNumbers.removeAt(0);
  }
  return currentNumbers;
}

double calculateRR(double heartRate) {
  return 60000 / heartRate;
}

double calculateRootMeanSquareDifference(List<double> numbers) {
  if (numbers.isEmpty) {
    throw ArgumentError('The list must not be empty.');
  }

  double sumOfSquaredDifferences = 0;
  double difference = 0;
  double previousValue = calculateRR(numbers[0]);
  double RR = 0;

  for (var number in numbers) {
    RR = calculateRR(number);
    difference = (RR - previousValue).abs();
    sumOfSquaredDifferences += pow(difference, 2);
    previousValue = RR;
  }

  double rootMeanSquareDifference =
      sqrt(sumOfSquaredDifferences / numbers.length);

  return rootMeanSquareDifference;
}
